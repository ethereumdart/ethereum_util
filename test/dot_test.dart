import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:convert/convert.dart' show hex;

import 'package:ethereum_util/ethereum_util.dart';

void main() {
  const String TEST_MNEMONIC =
      'caution juice atom organ advance problem want pledge someone senior holiday very';

  /// ********************************************start*******************************************
  test(' dot demo', () async {
    /// address generate, default prefix 0;
    final address = await Dot.mnemonicToAddress(TEST_MNEMONIC);
    expect(address, '15rRgsWxz4H5LTnNGcCFsszfXD8oeAFd8QRsR6MbQE2f6XFF');

    /// sign message
    final privateKey = hex.decode(
        'c8fa03532fb22ee1f7f6908b9c02b4e72483f0dbd66e4cd456b8f34c6230b849');
    final publicKey = hex.decode(
        'd6a3105d6768e956e9e5d41050ac29843f98561410d3a47f9dd5b3b227ab8746');
    /// without 0x9c
    final message =
        '0500009ea0acfa4a4b5a19c512df75afc9b1d5a9e1a1acf872018f956c8526e11efa00028907003500140041420f001800000091b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3bd44f5a7b303737a78347cc54297aec16442b91f9db5f074027d152ac4d80c68';
    final signedMessage =
        Dot.signature(message, Uint8List.fromList(privateKey));
    assert(Dot.verifySignedMessage(
        Uint8List.fromList(publicKey), signedMessage, message));
  });

  /// ********************************************end*******************************************
  group('test dot address generate by', () {
    test(' mnemonic 12', () async {
      final Uint8List privateKey =
          await Dot.mnemonicToPrivateKey(TEST_MNEMONIC);
      expect(hex.encode(privateKey),
          'c8fa03532fb22ee1f7f6908b9c02b4e72483f0dbd66e4cd456b8f34c6230b849');
      final publicKey = Dot.privateKeyToPublicKey(privateKey);
      expect(hex.encode(publicKey),
          'd6a3105d6768e956e9e5d41050ac29843f98561410d3a47f9dd5b3b227ab8746');
      String address = Dot.publicKeyToAddress(publicKey, prefix: 42);
      expect(address, '5Gv8YYFu8H1btvmrJy9FjjAWfb99wrhV3uhPFoNEr918utyR');
      address = Dot.publicKeyToAddress(publicKey, prefix: 0); // 默认地址
      expect(address, '15rRgsWxz4H5LTnNGcCFsszfXD8oeAFd8QRsR6MbQE2f6XFF');
      address = Dot.publicKeyToAddress(publicKey, prefix: 2);
      expect(address, 'HRkCrbmke2XeabJ5fxJdgXWpBRPkXWfWHY8eTeCKwDdf4k6');
      address = await Dot.mnemonicToAddress(TEST_MNEMONIC);
      expect(address, '15rRgsWxz4H5LTnNGcCFsszfXD8oeAFd8QRsR6MbQE2f6XFF');
    });
  });

  group('test signature transition', () {
    const mnemonic =
        'caution juice atom organ advance problem want pledge someone senior holiday very';
    late final privateKey;
    late final publicKey;

    late final signedRawMessage;
    late final signedMessage;
    late final signedMessageBytes;

    final rawMessage =
        '0x9c0500009ea0acfa4a4b5a19c512df75afc9b1d5a9e1a1acf872018f956c8526e11efa00028907003500140041420f001800000091b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3bd44f5a7b303737a78347cc54297aec16442b91f9db5f074027d152ac4d80c68';
    final unsignedMessage =
        '0500009ea0acfa4a4b5a19c512df75afc9b1d5a9e1a1acf872018f956c8526e11efa00028907003500140041420f001800000091b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3bd44f5a7b303737a78347cc54297aec16442b91f9db5f074027d152ac4d80c68';
    final unsignedMessageBytes =
        Uint8List.fromList(hex.decode(unsignedMessage));
    test('process message', () {
      final messageBytes = processMessage(rawMessage);
      expect(messageBytes, unsignedMessageBytes);
    });
    test('by private key', () async {
      privateKey = await Dot.mnemonicToPrivateKey(mnemonic);
      publicKey = Dot.privateKeyToPublicKey(privateKey);
      signedRawMessage = Dot.signature(rawMessage, privateKey);
      signedMessage = Dot.signature(unsignedMessage, privateKey);
      signedMessageBytes = Dot.signature(unsignedMessageBytes, privateKey);
      var result =
          Dot.verifySignedMessage(publicKey, signedRawMessage, unsignedMessage);
      assert(result);
      result =
          Dot.verifySignedMessage(publicKey, signedMessage, unsignedMessage);
      assert(result);
      result = Dot.verifySignedMessage(
          publicKey, signedMessageBytes, unsignedMessage);
      assert(result);
    });
  });
}
