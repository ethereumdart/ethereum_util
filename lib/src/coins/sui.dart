import 'package:pointycastle/digests/blake2b.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:convert/convert.dart' show hex;

import 'package:ethereum_util/src/coins/utils/crypto.dart';

const SUI_ADDRESS_LENGTH = 32;
const SUI_PATH = "m/44'/784'/0'/0'/0'";

class SuiCoin {
  /// Generates Sui seed by mnemonic
  static Future<Uint8List> mnemonicToPrivateKey(String mnemonic) async {
    final privateKey = await Crypto.bip44DerivePath(mnemonic, SUI_PATH);
    return Uint8List.fromList(privateKey);
  }

  /// Generates new Pair key by mnemonic
  static Uint8List privateKeyToPublicKey(Uint8List privateKey) {
    return ED25519.privateKeyToPublicKey(privateKey);
  }

  /// Constructs public key to Black2bHash
  static String publicKeyToBlack2bHash(Uint8List publicKey) {
    final suiBytes = new Uint8List(publicKey.length + 1);
    suiBytes[0] = 0;
    suiBytes.setRange(1, suiBytes.length, publicKey);
    final digest = Blake2bDigest(digestSize: 32);
    digest.update(suiBytes, 0, suiBytes.length);
    final hash = Uint8List(digest.digestSize);
    digest.doFinal(hash, 0);
    final hexes =
        List<String>.generate(256, (i) => i.toRadixString(16).padLeft(2, '0'));
    String _hex = '';
    for (int i = 0; i < hash.length; i++) {
      _hex += hexes[hash[i]];
    }
    return _hex;
  }

  /// Constructs the Sui address associated with given public key
  static String publicKeyToAddress(Uint8List publicKey) {
    final hash = publicKeyToBlack2bHash(publicKey);
    final slicedHash = hash.substring(0, SUI_ADDRESS_LENGTH * 2);
    return '0x${slicedHash.toLowerCase().padLeft(SUI_ADDRESS_LENGTH * 2, '0')}';
  }

  /// Generates the sui address associated with mnemonic
  static Future<String> mnemonicToAddress(String mnemonic) async {
    final privateKey = await mnemonicToPrivateKey(mnemonic);
    final publicKey = privateKeyToPublicKey(privateKey);
    return publicKeyToAddress(publicKey);
  }

  /// pure Ed25519 signature
  static String sign(Uint8List message, Uint8List privateKey) {
    final signedMessage = ED25519.sign(privateKey, message);
    return hex.encode(signedMessage);
  }

  static SignedMessage signReturnRaw(Uint8List message, Uint8List privateKey) {
    SigningKey signingKey = ED25519.generateKeyPair(privateKey);
    return signingKey.sign(message);
  }

  static bool verify(Uint8List publicKey, SignedMessage signedMessage) {
    VerifyKey verifyKey = new VerifyKey(Uint8List.fromList(publicKey));
    return verifyKey.verify(
        signature: signedMessage.signature,
        message: Uint8List.fromList(signedMessage.message));
  }
}
