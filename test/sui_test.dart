import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:convert/convert.dart' show hex;

import 'package:ethereum_util/src/sui.dart' as sui;

void main() {
  const String TEST_MNEMONIC =
      'cost leave absorb violin blur crack attack pig rice glide orient employ';
  group('test sui address generate by', () {
    test(' mnemonic 12', () async {
      final String address = await sui.mnemonicToSuiAddress(TEST_MNEMONIC);
      expect(address,
          '0x4fc033d8edde03af8ec50746b437ffd6292c13f5334bbdbc4c87f8d6d691a70b');
    });

    test(' mnemonic 24', () async {
      const String TEST_MNEMONIC =
          'soul celery start direct frozen link copy before point labor unfold remember chuckle panel mule priority tongue acid mosquito arrange fatal siege lizard ritual';
      final String address = await sui.mnemonicToSuiAddress(TEST_MNEMONIC);
      expect(address,
          '0x0713621bc01a1770bc6ab79c4516979376908c7afc7d83177481f1f59624ff6c');
    });
  });

  group('test signature transition', () {
    final message =
        '6fce5974ae960a8b5d32c2b073aac191d66cdd96346595b1378c8a0b7467d005';
    Uint8List messageList = Uint8List.fromList(hex.decode(message));
    final privateKey =
        '9542cbb380e050054781166580b1bb0ce45ed90c14ea1999f735f20f9791cc03';
    Uint8List keyList = Uint8List.fromList(hex.decode(privateKey));
    late final signingKey = sui.generateNewPairKeyBySeed(keyList);
    late final signedMessage;

    test('by private key', () {
      expect(hex.encode(signingKey.publicKey),
          'e78f607949ef9fabb96152f80a9ae4b19e0ac6d086c7bbd6f34faeee8ec5bfec');
      signedMessage = sui.suiSignatureFromSeed(messageList, keyList);
      expect(hex.encode(signedMessage.signature),
          'efdae4a66a3764ba4fee4b540dace1bff912b94193742b5ffc24a9d384551ea8b080d1b0a0087c77a849bd4d1f909e1fb582a3a2cc4051b4e20f7e484c35570b');
    });

    test('verify signature', () async {
      final result = sui.suiVerifySignedMessage(
          Uint8List.fromList(signingKey.publicKey), signedMessage);
      assert(result);
    });
  });
}
