import 'dart:math';
import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:collection/collection.dart' show ListEquality;
import 'package:convert/convert.dart';
import 'package:equatable/equatable.dart';
import 'package:ethereum_util/src/bytes.dart';
import 'package:ethereum_util/src/hash.dart';
import 'package:ethereum_util/src/random.dart';
import 'package:pointycastle/digests/sha256.dart';
import 'package:pointycastle/digests/sha3.dart';
import 'package:pointycastle/ecc/curves/secp256k1.dart';
import 'package:pointycastle/key_generators/ec_key_generator.dart';
import 'package:pointycastle/macs/hmac.dart';
import 'package:pointycastle/pointycastle.dart';
import 'package:pointycastle/signers/ecdsa_signer.dart';
import 'package:pointycastle/src/utils.dart';

final ECDomainParameters params = ECCurve_secp256k1();
final BigInt _halfCurveOrder = params.n ~/ BigInt.two;

const int _shaBytes = 256 ~/ 8;
final SHA3Digest sha3digest = SHA3Digest(_shaBytes * 8);

/// Signatures used to sign Ethereum transactions and messages.
class ECDSASignature extends Equatable {
  final BigInt r;
  final BigInt s;
  final int v;

  ECDSASignature(this.r, this.s, this.v) : super([r, s, v]);
}

Uint8List sha3(Uint8List input) {
  sha3digest.reset();
  return sha3digest.process(input);
}

/// Generates a new private key using the random instance provided. Please make
/// sure you're using a cryptographically secure generator.
BigInt generateNewPrivateKey(Random random) {
  final generator = ECKeyGenerator();

  final keyParams = ECKeyGeneratorParameters(params);

  generator.init(ParametersWithRandom(keyParams, DartRandom(random)));

  final key = generator.generateKeyPair();
  final privateKey = key.privateKey as ECPrivateKey;
  return privateKey.d;
}

/// Generates a public key for the given private key using the ecdsa curve which
/// Ethereum uses.
Uint8List privateKeyToPublicKey(Uint8List privateKey) {
  final privateKeyNum = decodeBigInt(privateKey);
  final p = params.G * privateKeyNum;

  //skip the type flag, https://github.com/ethereumjs/ethereumjs-util/blob/master/index.js#L319
  return Uint8List.view(p.getEncoded(false).buffer, 1);
}

/// Constructs the Ethereum address associated with the given public key by
/// taking the lower 160 bits of the key's sha3 hash.
Uint8List publicKeyToAddress(Uint8List publicKey) {
  assert(publicKey.length == 64);

  final hashed = sha3digest.process(publicKey);
  return Uint8List.view(hashed.buffer, _shaBytes - 20);
}

/// Signs the hashed data in [message] using the given private key.
ECDSASignature sign(Uint8List message, Uint8List privateKey, {int chainId = null}) {
  final digest = SHA256Digest();
  final signer = ECDSASigner(null, HMac(digest, 64));
  final key = ECPrivateKey(decodeBigInt(privateKey), params);

  signer.init(true, PrivateKeyParameter(key));
  var sig = signer.generateSignature(message) as ECSignature;

  /*
	This is necessary because if a message can be signed by (r, s), it can also
	be signed by (r, -s (mod N)) which N being the order of the elliptic function
	used. In order to ensure transactions can't be tampered with (even though it
	would be harmless), Ethereum only accepts the signature with the lower value
	of s to make the signature for the message unique.
	More details at
	https://github.com/web3j/web3j/blob/master/crypto/src/main/java/org/web3j/crypto/ECDSASignature.java#L27
	 */
  if (sig.s.compareTo(_halfCurveOrder) > 0) {
    final canonicalisedS = params.n - sig.s;
    sig = ECSignature(sig.r, canonicalisedS);
  }

  // Now we have to work backwards to figure out the recId needed to recover the signature.
  //https://github.com/web3j/web3j/blob/master/crypto/src/main/java/org/web3j/crypto/Sign.java
  final publicKey = privateKeyToPublicKey(privateKey);
  int recoveryId = -1;
  for (var i = 0; i < 2; i++) {
    final k = _recoverPublicKeyFromSignature(i, sig.r, sig.s, message);
    if (ListEquality().equals(k, publicKey)) {
      recoveryId = i;
      break;
    }
  }

  if (recoveryId == -1) {
    throw Exception('Could not construct a recoverable key. This should never happen');
  }

  return ECDSASignature(
    sig.r,
    sig.s,
    chainId != null ? recoveryId + (chainId * 2 + 35) : recoveryId + 27,
  );
}

bool isValidSignature(BigInt r, BigInt s, int v, {bool homesteadOrLater = true, int chainId = null}) {
  var SECP256K1_N_DIV_2 = decodeBigInt(hex.decode('7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0'));
  var SECP256K1_N = decodeBigInt(hex.decode('fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141'));

  if (encodeBigInt(r).length != 32 || encodeBigInt(s).length != 32) {
    return false;
  }

  if (!_isValidSigRecovery(_calculateSigRecovery(v, chainId: chainId))) {
    return false;
  }

  if (r == BigInt.zero || r > SECP256K1_N || s == BigInt.zero || s > SECP256K1_N) {
    return false;
  }

  if (homesteadOrLater && s > SECP256K1_N_DIV_2) {
    return false;
  }

  return true;
}

Uint8List recoverPublicKeyFromSignature(ECDSASignature sig, Uint8List message, {int chainId = null}) {
  int recoveryId = _calculateSigRecovery(sig.v, chainId: chainId);
  if (!_isValidSigRecovery(recoveryId)) {
    throw ArgumentError("invalid signature v value");
  }

  if (!isValidSignature(sig.r, sig.s, sig.v, chainId: chainId)) {
    throw ArgumentError("invalid signature");
  }

  return _recoverPublicKeyFromSignature(recoveryId, sig.r, sig.s, message);
}

Uint8List _recoverPublicKeyFromSignature(int recId, BigInt r, BigInt s, Uint8List message) {
  final n = params.n;
  final i = BigInt.from(recId ~/ 2);
  final x = r + (i * n);

  //Parameter q of curve
  final prime = BigInt.parse('fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f', radix: 16);
  if (x.compareTo(prime) >= 0) return null;

  final R = _decompressKey(x, (recId & 1) == 1, params.curve);
  if (!(R * n).isInfinity) return null;

  final e = decodeBigInt(message);

  final eInv = (BigInt.zero - e) % n;
  final rInv = r.modInverse(n);
  final srInv = (rInv * s) % n;
  final eInvrInv = (rInv * eInv) % n;

  final q = (params.G * eInvrInv) + (R * srInv);

  final bytes = q.getEncoded(false);
  return bytes.sublist(1);
}

int _calculateSigRecovery(int v, {int chainId = null}) {
  return chainId != null ? v - (2 * chainId + 35) : v - 27;
}

bool _isValidSigRecovery(int recoveryId) {
  return recoveryId == 0 || recoveryId == 1;
}

ECPoint _decompressKey(BigInt xBN, bool yBit, ECCurve c) {
  List<int> x9IntegerToBytes(BigInt s, int qLength) {
    //https://github.com/bcgit/bc-java/blob/master/core/src/main/java/org/bouncycastle/asn1/x9/X9IntegerConverter.java#L45
    final bytes = encodeBigInt(s);

    if (qLength < bytes.length) {
      return bytes.sublist(0, bytes.length - qLength);
    } else if (qLength > bytes.length) {
      final tmp = List<int>.filled(qLength, 0);

      final offset = qLength - bytes.length;
      for (var i = 0; i < bytes.length; i++) {
        tmp[i + offset] = bytes[i];
      }

      return tmp;
    }

    return bytes;
  }

  final compEnc = x9IntegerToBytes(xBN, 1 + ((c.fieldSize + 7) ~/ 8));
  compEnc[0] = yBit ? 0x03 : 0x02;
  return c.decodePoint(compEnc);
}

///
/// Returns the keccak-256 hash of `message`, prefixed with the header used by the `eth_sign` RPC call.
/// The output of this function can be fed into `ecsign` to produce the same signature as the `eth_sign`
/// call for a given `message`, or fed to `ecrecover` along with a signature to recover the public key
/// used to produce the signature.
///
Uint8List hashPersonalMessage(dynamic message) {
  var prefix = toBuffer("\u0019Ethereum Signed Message:\n${message.length.toString()}");
  var bytesBuffer = BytesBuffer();
  bytesBuffer.add(prefix);
  bytesBuffer.add(message);
  return keccak(bytesBuffer.toBytes());
}

///
/// Convert signature parameters into the format of `eth_sign` RPC method.
///
String toRpcSig(BigInt r, BigInt s, int v, {int chainId = null}) {
  var recovery = _calculateSigRecovery(v, chainId: chainId);
  if (!_isValidSigRecovery(recovery)) {
    throw ArgumentError('Invalid signature v value');
  }

  // geth (and the RPC eth_sign method) uses the 65 byte format used by Bitcoin
  var bytesBuffer = BytesBuffer();
  var rbuf = encodeBigInt(r);
  var sbuf = encodeBigInt(s);
  bytesBuffer.add(setLengthLeft(rbuf, 32));
  bytesBuffer.add(setLengthLeft(sbuf, 32));
  bytesBuffer.add(toBuffer(v));
  return bufferToHex(bytesBuffer.toBytes());
}

///
/// Convert signature format of the `eth_sign` RPC method to signature parameters
/// NOTE: all because of a bug in geth: https://github.com/ethereum/go-ethereum/issues/2053
///
ECDSASignature fromRpcSig(String sig) {
  Uint8List buf = toBuffer(sig);

  // NOTE: with potential introduction of chainId this might need to be updated
  if (buf.length != 65) {
    throw ArgumentError('Invalid signature length');
  }

  var v = buf[64];
  // support both versions of `eth_sign` responses
  if (v < 27) {
    v += 27;
  }

  return ECDSASignature(
    decodeBigInt(Uint8List.view(buf.buffer, 0, 32)),
    decodeBigInt(Uint8List.view(buf.buffer, 32, 32)),
    v,
  );
}
