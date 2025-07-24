import 'dart:convert';
import 'dart:io';

import 'package:test/test.dart';

import 'package:ethereum_util/ethereum_util.dart';

void main() {
  const String TEST_MNEMONIC =
      'keep find oxygen first depend urge fix unit stairs miss danger transfer';
  group('test xrp address generate by', () {
    test(' mnemonic 12', () async {
      final String address = await XrpCoin.mnemonicToAddress(TEST_MNEMONIC);
      expect(address, 'rJKQz9LY8BaNeeYBR4gKt1m8knzgNU97eb');
    });
  });

  group('test mnemonic to privateKey', () {
    test(' mnemonic 12', () async {
      final privateKey = await XrpCoin.mnemonicToPrivateKey(TEST_MNEMONIC);
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
      final publicKey = XrpCoin.privateKeyToPublicKey(privateKey);

      final XrpTxData tx = new XrpTxData(
          account: txJson["Account"],
          transactionType: txJson["TransactionType"],
          sequence: txJson["Sequence"],
          fee: txJson["Fee"],
          lastLedgerSequence: txJson["LastLedgerSequence"],
          signingPubKey: publicKey,
          destination: txJson["Destination"],
          amount: txJson["Amount"]);
      final signedMessage = XrpCoin.sign(privateKey, tx);
      expect(signedMessage, txResult);
    });

    test(' signature token transaction', () async {
      final txJson = transactionJson['payment_token'];
      final txResult = txJson['txSignature'];
      final publicKey = XrpCoin.privateKeyToPublicKey(privateKey);
      final tokenAmount = new XrpTokenAmount(
          currency: txJson['Amount']['currency'],
          issuer: txJson['Amount']['issuer'],
          value: txJson['Amount']['value']);
      final XrpTxData tx = new XrpTxData(
          account: txJson["Account"],
          transactionType: txJson["TransactionType"],
          sequence: txJson["Sequence"],
          fee: txJson["Fee"],
          lastLedgerSequence: txJson["LastLedgerSequence"],
          signingPubKey: publicKey,
          destination: txJson["Destination"],
          amount: tokenAmount);
      final signedMessage = XrpCoin.sign(privateKey, tx);
      expect(signedMessage, txResult);
    });

    test(' signature trust set transaction', () async {
      final txJson = transactionJson['trust_set'];
      final txResult = txJson['txSignature'];
      final publicKey = XrpCoin.privateKeyToPublicKey(privateKey);
      final limitAmount = new XrpTokenAmount(
          currency: txJson['LimitAmount']['currency'],
          issuer: txJson['LimitAmount']['issuer'],
          value: txJson['LimitAmount']['value']);
      final XrpTxData tx = new XrpTxData(
          account: txJson["Account"],
          transactionType: txJson["TransactionType"],
          sequence: txJson["Sequence"],
          fee: txJson["Fee"],
          lastLedgerSequence: txJson["LastLedgerSequence"],
          signingPubKey: publicKey,
          limitAmount: limitAmount);
      final signedMessage = XrpCoin.sign(privateKey, tx);
      expect(signedMessage, txResult);
    });
  });
}
