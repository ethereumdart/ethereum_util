import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:convert/convert.dart' show hex;

import 'package:ethereum_util/ethereum_util.dart';

void main() {
  const String TEST_MNEMONIC =
      'caution juice atom organ advance problem want pledge someone senior holiday very';
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
        'asset mix describe spare brand renew siege twelve toilet stairs stomach scrap';
    late final signedMessage;
    late final privateKey;
    late final publicKey;

    final message =
        '0500009ea0acfa4a4b5a19c512df75afc9b1d5a9e1a1acf872018f956c8526e11efa00028907003500140041420f001800000091b171bb158e2d3848fa23a9f1c25182fb8e20313b2c1eb49219da7a70ce90c3bd44f5a7b303737a78347cc54297aec16442b91f9db5f074027d152ac4d80c68';

    test('by private key', () async {
      privateKey = await Dot.mnemonicToPrivateKey(mnemonic);
      publicKey = Dot.privateKeyToPublicKey(privateKey);
      final messageBytes = Uint8List.fromList(hex.decode(message));
      signedMessage = Dot.signature(messageBytes, privateKey);
      var result = Dot.verifySignedMessage(publicKey, signedMessage, message);
      assert(result);
    });
  });
}
