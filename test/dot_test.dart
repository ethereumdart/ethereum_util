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
    expect(address, '12BEGDJA1T4UxkPBUGTAvTy1FsVd6Q2NtndEB5Y7CoPKUfLh');

    /// sign message
    final privateKey = hex.decode(
        'c5df21329fd21bdb4c07093964d78e26aebbd5bc8bf8560dbe3513c4e497ef8b');
    final publicKey = hex.decode(
        '3409551163fe49e947748bef3db9e6b2eb4b69d583f0b1b506a6c8b627c5086a');
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
          'c5df21329fd21bdb4c07093964d78e26aebbd5bc8bf8560dbe3513c4e497ef8b');
      final publicKey = Dot.privateKeyToPublicKey(privateKey);
      expect(hex.encode(publicKey),
          '3409551163fe49e947748bef3db9e6b2eb4b69d583f0b1b506a6c8b627c5086a');
      String address = Dot.publicKeyToAddress(publicKey, prefix: 42);
      expect(address, '5DEw7t369fo1XDNfWdQAnK8rQFVyQ6UEpHtk1nYkeiMoJGym');
      address = Dot.publicKeyToAddress(publicKey, prefix: 0); // 默认地址
      expect(address, '12BEGDJA1T4UxkPBUGTAvTy1FsVd6Q2NtndEB5Y7CoPKUfLh');
      address = Dot.publicKeyToAddress(publicKey, prefix: 2);
      expect(address, 'DkYnCNxn2owGsC7HLDDgGVrYqnDCmHRGfjVQSpi8WaJ3JpG');
      address = await Dot.mnemonicToAddress(TEST_MNEMONIC);
      expect(address, '12BEGDJA1T4UxkPBUGTAvTy1FsVd6Q2NtndEB5Y7CoPKUfLh');
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
