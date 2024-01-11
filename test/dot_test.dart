import 'dart:typed_data';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:convert/convert.dart' show hex;

import 'package:ethereum_util/src/dot.dart' as dot;

void main() {
  const String TEST_MNEMONIC =
      'caution juice atom organ advance problem want pledge someone senior holiday very';
  group('test dot address generate by', () {
    test(' mnemonic 12', () async {
      final Uint8List privateKey =
          await dot.mnemonicToPrivateKey(TEST_MNEMONIC);
      expect(hex.encode(privateKey),
          'c8fa03532fb22ee1f7f6908b9c02b4e72483f0dbd66e4cd456b8f34c6230b849');
      final publicKey = dot.privateKeyToPublicKey(privateKey);
      expect(hex.encode(publicKey),
          'd6a3105d6768e956e9e5d41050ac29843f98561410d3a47f9dd5b3b227ab8746');
      String address = dot.publicKeyToAddress(publicKey, prefix: 42);
      expect(address, '5Gv8YYFu8H1btvmrJy9FjjAWfb99wrhV3uhPFoNEr918utyR');
      address = dot.publicKeyToAddress(publicKey, prefix: 0); // 默认地址
      expect(address, '15rRgsWxz4H5LTnNGcCFsszfXD8oeAFd8QRsR6MbQE2f6XFF');
      address = dot.publicKeyToAddress(publicKey, prefix: 2);
      expect(address, 'HRkCrbmke2XeabJ5fxJdgXWpBRPkXWfWHY8eTeCKwDdf4k6');
      address = await dot.mnemonicToAddress(TEST_MNEMONIC);
      expect(address, '15rRgsWxz4H5LTnNGcCFsszfXD8oeAFd8QRsR6MbQE2f6XFF');
    });
  });

  // group('test signature transition', () {
  //   late final signedMessage;
  //   // final privateKey =
  //   //     'de71be0feb95ac763f71ab4b70c537be89af2549eb8ce1d3eca3115a48c5bd3f';
  //   final privateKey = 'cb6564854374eac1818e2b909d8a1c742c547d6beb63a92a1edc7059d7fcf2f2';
  //   final publicKey =
  //       dot.privateKeyToPublicKey(Uint8List.fromList(hex.decode(privateKey)));
  //   print(dot.publicKeyToAddress(publicKey));
  //   final message = '9c0500009ea0acfa4a4b5a19c512df75afc9b1d5a9e1a1acf872018f956c8526e11efa00028907005501080041420f001800000091b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c356fa869e599cbc6629faa39a70e318b0cadde91ad50c4fb8cdb6fe74010b4f9e';


  //   test('by private key', () {
    
  //     final keyBytes = Uint8List.fromList(hex.decode(privateKey));
  //     final messageBytes = Uint8List.fromList(hex.decode(message));
  //     signedMessage = dot.signature(messageBytes, keyBytes);
  //     // expect(signedMessage,
  //     //     'efdae4a66a3764ba4fee4b540dace1bff912b94193742b5ffc24a9d384551ea8b080d1b0a0087c77a849bd4d1f909e1fb582a3a2cc4051b4e20f7e484c35570b');
  //   });

  //   test('verify signature', () async {
  //     final result =
  //         dot.verifySignedMessage(publicKey, signedMessage, 'message');
  //   });
  // });
}
