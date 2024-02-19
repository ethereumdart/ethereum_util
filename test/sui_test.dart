import 'dart:typed_data';
import 'dart:convert';

import 'package:test/test.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:convert/convert.dart' show hex;

import 'package:ethereum_util/src/coins/sui.dart';

void main() {
  const String TEST_MNEMONIC =
      'cost leave absorb violin blur crack attack pig rice glide orient employ';
  group('test sui address generate by', () {
    test(' mnemonic 12', () async {
      final String address = await SuiCoin.mnemonicToAddress(TEST_MNEMONIC);
      expect(address,
          '0x4fc033d8edde03af8ec50746b437ffd6292c13f5334bbdbc4c87f8d6d691a70b');

      /// mnemonic to private key
      final privateKey = await SuiCoin.mnemonicToPrivateKey(TEST_MNEMONIC);
      expect(hex.encode(privateKey),
          '729215013d83ae9ee5058ea8c9e263dd6dc62df13272cddc2082b63187fcb966');

      /// private key to key pair
      final publicKey = SuiCoin.privateKeyToPublicKey(privateKey);
      final message =
          'ef80aa12944ed4ddfbd701afc5117865784de618afb64d2f29ecaeb95e6ebe43';
      Uint8List messageList = Uint8List.fromList(hex.decode(message));

      /// sign message
      final signedMessage = SuiCoin.signReturnRaw(messageList, privateKey);
      final signMessageHash = SuiCoin.sign(messageList, privateKey);
      expect(hex.encode(signedMessage.signature), signMessageHash);
      final result =
          SuiCoin.verify(Uint8List.fromList(publicKey), signedMessage);
      assert(result);
    });

    test(' mnemonic 24', () async {
      const String TEST_MNEMONIC =
          'soul celery start direct frozen link copy before point labor unfold remember chuckle panel mule priority tongue acid mosquito arrange fatal siege lizard ritual';
      final String address = await SuiCoin.mnemonicToAddress(TEST_MNEMONIC);
      expect(address,
          '0x0713621bc01a1770bc6ab79c4516979376908c7afc7d83177481f1f59624ff6c');
    });
  });

  group('test signature transition', () {
    // https://suiexplorer.com/txblock/EqmzdPhCjDrLKsgUCT5VCuP2VKywCRiqEzao4aTVPxnK
    final message =
        '6fce5974ae960a8b5d32c2b073aac191d66cdd96346595b1378c8a0b7467d005';
    Uint8List messageList = Uint8List.fromList(hex.decode(message));
    final privateKey =
        '9542cbb380e050054781166580b1bb0ce45ed90c14ea1999f735f20f9791cc03';
    Uint8List keyList = Uint8List.fromList(hex.decode(privateKey));
    late final signingKey = SuiCoin.privateKeyToPublicKey(keyList);
    late final signedMessage;
    String publicKeyBase = 'AOePYHlJ75+ruWFS+Aqa5LGeCsbQhse71vNPru6Oxb/s';
    Uint8List publicKeyRaw = base64.decode(publicKeyBase);
    Uint8List publicKey = publicKeyRaw.sublist(1, publicKeyRaw.length);

    // String signatureBase =
    //     'crHI/Y+bCOfVBw7BDHWOjvGAbEBk2jdbQaOd72CrJhsxymPCXayEKTDaOHB+T16lULwA8I5gVgLn1/JXRn28Bg==';
    // Uint8List signatureRaw = base64.decode(signatureBase);
    test('by private key', () {
      expect(signingKey, publicKey);
      signedMessage = SuiCoin.sign(messageList, keyList);
      expect(signedMessage,
          'efdae4a66a3764ba4fee4b540dace1bff912b94193742b5ffc24a9d384551ea8b080d1b0a0087c77a849bd4d1f909e1fb582a3a2cc4051b4e20f7e484c35570b');
    });

    test('verify signature', () async {
      final signedMessage = SuiCoin.signReturnRaw(messageList, keyList);
      final result =
          SuiCoin.verify(Uint8List.fromList(signingKey), signedMessage);
      assert(result);
    });
  });
}
