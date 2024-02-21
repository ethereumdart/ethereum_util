import 'package:xrp_dart/xrp_dart.dart';

import 'package:ethereum_util/src/coins/utils/crypto.dart';

/// Generates Sui seed by mnemonic
const XRP_PATH = "m/44'/144'/0'/0/0";

class XrpCoin {
  static mnemonicToAddress(String mnemonic) {
    final privateKey = mnemonicToPrivateKey(mnemonic);
    final wallet = privateKeyToWallet(privateKey);
    return wallet.getPublic().toAddress().toString();
  }

  static String mnemonicToPrivateKey(String mnemonic) {
    final privateKey = Crypto.bip32DerivePath(mnemonic, XRP_PATH);
    return dynamicToHex(privateKey);
  }

  static String privateKeyToPublicKey(String privateKey) {
    final wallet = privateKeyToWallet(privateKey);
    return wallet.getPublic().toHex();
  }

  static XRPPrivateKey privateKeyToWallet(String privateKey) {
    var key = privateKey;
    final keyPrefix = privateKey.substring(0, 2);
    if (keyPrefix != '00') key = '00' + key; // 处理私钥
    return XRPPrivateKey.fromHex(key);
  }

  static String sign(String privateKey, XrpTxData txData) {
    final wallet = privateKeyToWallet(privateKey);
    final tx = XRPTransaction.fromXrpl(txData.toJson());
    final signed = wallet.sign(tx.toBlob()); // 签名
    tx.txnSignature = signed; // 加入
    return tx.toBlob(forSigning: false);
  }
}

class XrpTxData {
  XrpTxData({
    required this.account,
    required this.transactionType,
    this.destination,
    this.amount,
    this.limitAmount,
    this.flags = 0,
    required this.sequence,
    required this.fee,
    required this.lastLedgerSequence,
    required this.signingPubKey,
  });
  final String account;
  final String transactionType;
  final String? destination;
  final dynamic amount;
  final XrpTokenAmount? limitAmount;
  final int flags;
  final int sequence;
  final String fee;
  final int lastLedgerSequence;
  final String signingPubKey;
  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      "Account": this.account,
      "TransactionType": this.transactionType,
      "Flags": this.flags,
      "Sequence": this.sequence,
      "Fee": this.fee,
      "LastLedgerSequence": this.lastLedgerSequence,
      "SigningPubKey": this.signingPubKey
    };
    switch (this.transactionType) {
      case XrpTransactionType.payment:
        json = {...json, "Destination": this.destination};
        if (amount is String) {
          return {...json, "Amount": this.amount};
        } else if (amount is XrpTokenAmount) {
          return {...json, "Amount": this.amount.toJson()};
        } else {
          throw Exception('unsupported amount format');
        }
      case XrpTransactionType.trustSet:
        return {...json, "LimitAmount": this.limitAmount!.toJson()};
      default:
        throw Exception('unsupported transaction type');
    }
  }
}

class XrpTokenAmount {
  XrpTokenAmount(
      {required this.currency, required this.issuer, required this.value});
  final String currency;
  final String issuer;
  final String value;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      "currency": this.currency,
      "issuer": this.issuer,
      "value": this.value
    };
    return json;
  }
}

class XrpTransactionType {
  static const String payment = "Payment";
  static const String trustSet = "TrustSet";
}
