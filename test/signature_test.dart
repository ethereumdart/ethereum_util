import 'dart:typed_data';

import 'package:convert/convert.dart' show hex;
import 'package:test/test.dart';

import 'package:ethereum_util/src/utils/bigint.dart';
import 'package:ethereum_util/src/utils/bytes.dart';
import 'package:ethereum_util/src/signature.dart' as signature;

var echash = hex.decode('82ff40c0a986c6a5cfad4ddf4c3aa6996f1a7837f9c398e17e5de5cbd5a12b28');
var ecprivkey = hex.decode('3c9229289a6125f7fdf1885a77bb12c37a8d3b4962d936f7e3084dece32a3ca1');
var ropstenChainId = 3; // ropsten

void main() {
  group('sign', () {
    test('should produce a signature', () {
      var sig = signature.sign(Uint8List.fromList(echash), Uint8List.fromList(ecprivkey));
      expect(encodeBigInt(sig.r), hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      expect(encodeBigInt(sig.s), hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca66'));
      expect(sig.v, 27);
    });

    test('should produce a signature for Ropsten testnet', () {
      var sig = signature.sign(Uint8List.fromList(echash), Uint8List.fromList(ecprivkey), chainId: ropstenChainId);
      expect(encodeBigInt(sig.r), hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      expect(encodeBigInt(sig.s), hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca66'));
      expect(sig.v, 41);
    });
  });

  group('recoverPublicKeyFromSignature', () {
    test('should recover a public key', () {
      var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      var s = decodeBigInt(hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca66'));
      var v = 27;
      var pubKey = signature.recoverPublicKeyFromSignature(signature.ECDSASignature(r, s, v), Uint8List.fromList(echash));
      expect(pubKey, signature.privateKeyToPublicKey(Uint8List.fromList(ecprivkey)));
    });

    test('should recover a public key (ropstenChainId = 3)', () {
      var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      var s = decodeBigInt(hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca66'));
      var v = 41;
      var pubKey = signature.recoverPublicKeyFromSignature(signature.ECDSASignature(r, s, v), Uint8List.fromList(echash), chainId: ropstenChainId);
      expect(pubKey, signature.privateKeyToPublicKey(Uint8List.fromList(ecprivkey)));
    });

    test('should fail on an invalid signature (v = 21)', () {
      var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      var s = decodeBigInt(hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca66'));
      var v = 21;
      expect(() => signature.recoverPublicKeyFromSignature(signature.ECDSASignature(r, s, v), Uint8List.fromList(echash)), throwsArgumentError);
    });

    test('should fail on an invalid signature (v = 29)', () {
      var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      var s = decodeBigInt(hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca66'));
      var v = 29;
      expect(() => signature.recoverPublicKeyFromSignature(signature.ECDSASignature(r, s, v), Uint8List.fromList(echash)), throwsArgumentError);
    });

    test('should fail on an invalid signature (swapped points)', () {
      var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      var s = decodeBigInt(hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca66'));
      var v = 27;
      expect(() => signature.recoverPublicKeyFromSignature(signature.ECDSASignature(s, r, v), Uint8List.fromList(echash)), throwsArgumentError);
    });
  });

  group('hashPersonalMessage', () {
    test('should produce a deterministic hash', () {
      var h = signature.hashPersonalMessage(toBuffer('Hello world'));
      expect(h, hex.decode('8144a6fa26be252b86456491fbcd43c1de7e022241845ffea1c3df066f7cfede'));
    });
  });

  group('isValidSignature', () {
    test('should fail on an invalid signature (shorter r))', () {
      var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1ab'));
      var s = decodeBigInt(hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca66'));
      expect(signature.isValidSignature(r, s, 27), false);
    });
    test('should fail on an invalid signature (shorter s))', () {
      var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      var s = decodeBigInt(hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca'));
      expect(signature.isValidSignature(r, s, 27), false);
    });
    test('should fail on an invalid signature (v = 21)', () {
      var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      var s = decodeBigInt(hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca66'));
      expect(signature.isValidSignature(r, s, 21), false);
    });
    test('should fail on an invalid signature (v = 29)', () {
      var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      var s = decodeBigInt(hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca66'));
      expect(signature.isValidSignature(r, s, 29), false);
    });
    test('should fail when on homestead and s > secp256k1n/2', () {
      var SECP256K1_N_DIV_2 = decodeBigInt(hex.decode('7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0'));

      var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      var s = SECP256K1_N_DIV_2 + BigInt.one;

      var v = 27;
      expect(signature.isValidSignature(r, s, v, homesteadOrLater: true), false);
    });
    test('should not fail when not on homestead but s > secp256k1n/2', () {
      var SECP256K1_N_DIV_2 = decodeBigInt(hex.decode('7fffffffffffffffffffffffffffffff5d576e7357a4501ddfe92f46681b20a0'));

      var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      var s = SECP256K1_N_DIV_2 + BigInt.one;

      var v = 27;
      expect(signature.isValidSignature(r, s, v, homesteadOrLater: false), true);
    });
    test('should work otherwise', () {
      var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      var s = decodeBigInt(hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca66'));
      var v = 27;
      expect(signature.isValidSignature(r, s, v), true);
    });
    test('should work otherwise(ropstenChainId=3)', () {
      var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
      var s = decodeBigInt(hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca66'));
      var v = 41;
      expect(signature.isValidSignature(r, s, v, homesteadOrLater: false, chainId: ropstenChainId), true);
    });
  });

  group('message sig', () {
    var r = decodeBigInt(hex.decode('99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9'));
    var s = decodeBigInt(hex.decode('129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca66'));

    test('should return hex strings that the RPC can use', () {
      const v = 27;
      expect(signature.toRpcSig(r, s, v), '0x99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca661b');
      expect(
        signature.fromRpcSig( '0x99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca661b').toString(),
        signature.ECDSASignature(r, s, v).toString()
      );
      expect(
        signature.fromRpcSig('0x99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca6600').toString(),
        signature.ECDSASignature(r, s, v).toString()
      );
    });

    test('should throw on invalid length', () {
      expect(() => signature.fromRpcSig(''), throwsArgumentError);
      expect(() => signature.fromRpcSig('0x99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca660042'), throwsArgumentError);
    });

    test('pad short r and s values', () {
      const v = 27;
      expect(
        signature.toRpcSig(decodeBigInt(Uint8List.view(encodeBigInt(r).buffer, 20)), decodeBigInt(Uint8List.view(encodeBigInt(s).buffer, 20)), v),
        '0x00000000000000000000000000000000000000004a1579cf389ef88b20a1abe90000000000000000000000000000000000000000326fa689f228040429e3ca661b'
      );
    });

    test('should throw on invalid v value', () {
      const v = 1;
      expect(() => signature.toRpcSig(r, s, v), throwsArgumentError);
    });
  });
}
