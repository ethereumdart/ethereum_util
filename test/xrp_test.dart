import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:ethereum_util/ethereum_util.dart';

void main() {
  const String TEST_MNEMONIC =
      'keep find oxygen first depend urge fix unit stairs miss danger transfer';
  group('test xrp address generate by', () {
    test(' mnemonic 12', () async {
      final String address = await Xrp.mnemonicToAddress(TEST_MNEMONIC);
      expect(address, 'rJKQz9LY8BaNeeYBR4gKt1m8knzgNU97eb');
    });
  });

  group('test mnemonic to privateKey', () {
    test(' mnemonic 12', () async {
      final privateKey = await Xrp.mnemonicToPrivateKey(TEST_MNEMONIC);
      expect(privateKey,
          '3ed3297891ccade7fc53babb4783de5c079f68b41e2b3ef6b4ff3c8751e6be75');
    });
  });

  group('test signature transition', () {
    final transactionJson = json.decode(
        new File('./test/data/xrp.json').readAsStringSync(encoding: utf8));
    final privateKey =
        "3ed3297891ccade7fc53babb4783de5c079f68b41e2b3ef6b4ff3c8751e6be75";

    test(' signature xrp transaction', () async {
      final txJson = transactionJson['payment_xrp'];
      final txResult = txJson['txSignature'];
      final signedMessage = Xrp.sign(privateKey, txJson);
      expect(signedMessage, txResult);
    });

    test(' signature token transaction', () async {
      final txJson = transactionJson['payment_token'];
      final txResult = txJson['txSignature'];
      final signedMessage = Xrp.sign(privateKey, txJson);
      expect(signedMessage, txResult);
    });

    test(' signature trust set transaction', () async {
      final txJson = transactionJson['trust_set'];
      final txResult = txJson['txSignature'];
      final signedMessage = Xrp.sign(privateKey, txJson);
      expect(signedMessage, txResult);
    });
  });
}
