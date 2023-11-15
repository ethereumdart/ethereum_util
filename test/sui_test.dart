import 'package:test/test.dart';

import 'package:ethereum_util/src/sui.dart' as sui;

void main() {
  group('test sui address generate by', () {
    test(' mnemonic 12', () async {
      const String TEST_MNEMONIC =
          'cost leave absorb violin blur crack attack pig rice glide orient employ';
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
}
