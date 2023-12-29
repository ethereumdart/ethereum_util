import 'package:xrp_dart/xrp_dart.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:convert/convert.dart' show hex;

/// Generates Sui seed by mnemonic
const XRP_PATH = "m/44'/144'/0'/0/0";

String mnemonicToAddress(String mnemonic) {
  final wallet = mnemonicToWallet(mnemonic);
  final publicKey = wallet.getPublic();
  final addressClass = publicKey.toAddress();
  return addressClass.toString();
}

String mnemonicToPrivateKey(String mnemonic) {
  final seed = bip39.mnemonicToSeed(mnemonic);
  final keyChain = bip32.BIP32.fromSeed(seed);
  final keyPair = keyChain.derivePath(XRP_PATH);
  return hex.encode(keyPair.privateKey!);
}

XRPPrivateKey mnemonicToWallet(String mnemonic) {
  final toHex = mnemonicToPrivateKey(mnemonic);
  final wallet = XRPPrivateKey.fromHex('00' + toHex);
  return wallet;
}

XRPTransaction createTransaction(
    Map<String, Object?> originalTx, String publicKey) {
  final Map<String, dynamic> txData = {
    ...originalTx,
    "SigningPubKey": publicKey
  };
  final tx = XRPTransaction.fromXrpl(txData);
  return tx;
}

String sign(String privateKey, Map<String, Object?> originalTx) {
  var key = privateKey;
  final keyPrefix = privateKey.substring(0, 2);
  if (keyPrefix != '00') key = '00' + key; // 处理私钥
  final wallet = XRPPrivateKey.fromHex(key);
  final pubKey = wallet.getPublic().toHex();
  final tx = createTransaction(originalTx, pubKey); // 创建交易

  final signed = wallet.sign(tx.toBlob()); // 签名
  tx.txnSignature = signed; // 加入
  return tx.toBlob(forSigning: false);
}

// String camelToSnake(String input) {
//   String result = input.replaceAllMapped(RegExp(r'([A-Z])'), (Match match) {
//     return '_' + match.group(1)!.toLowerCase();
//   });
//   if (result.startsWith('_')) {
//     return result.replaceFirst('_', '');
//   }
//   return result;
// }
