import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:convert/convert.dart' show hex;
import 'package:pinenacl/ed25519.dart';
import "package:ed25519_hd_key/ed25519_hd_key.dart";

class Crypto {
  static Uint8List mnemonicToSeed(String mnemonic) {
    return bip39.mnemonicToSeed(mnemonic);
  }

  static Uint8List bip32DerivePath(String mnemonic, String path,
      {returnStr = false}) {
    final seed = mnemonicToSeed(mnemonic);
    final keyChain = bip32.BIP32.fromSeed(seed);
    final keyPair = keyChain.derivePath(path);
    return dynamicToUint8List(keyPair.privateKey!);
  }

  static Future<Uint8List> bip44DerivePath(String mnemonic, String path) async {
    final seed = mnemonicToSeed(mnemonic);
    final keyData = await ED25519_HD_KEY.derivePath(path, seed);
    return Uint8List.fromList(keyData.key);
  }
}

class ED25519 {
  static SigningKey generateKeyPair(Uint8List privateKey) {
    return SigningKey.fromSeed(privateKey);
  }

  static Uint8List privateKeyToPublicKey(Uint8List privateKey) {
    SigningKey keyPair = SigningKey.fromSeed(privateKey);
    return Uint8List.fromList(keyPair.publicKey);
  }

  static Uint8List sign(Uint8List privateKey, dynamic message) {
    SigningKey keyPair = SigningKey.fromSeed(privateKey);
    SignedMessage signedMessage = keyPair.sign(dynamicToUint8List(message));
    return Uint8List.fromList(signedMessage.signature);
  }

  static bool verify(Uint8List publicKey, dynamic signature, dynamic message) {
    VerifyKey verifyKey = new VerifyKey(Uint8List.fromList(publicKey));
    SignedMessage signedMessage =
        SignedMessage.fromList(signedMessage: dynamicToUint8List(signature));
    return verifyKey.verify(
        signature: signedMessage.signature,
        message: dynamicToUint8List(message));
  }
}

Uint8List dynamicToUint8List(dynamic value) {
  switch (value.runtimeType.toString()) {
    case 'List<int>':
      return Uint8List.fromList(value);
    case 'String':
      return Uint8List.fromList(hex.decode(value));
    case 'Uint8List':
      return value;
    default:
      throw Exception("value must be String, List<int> or Uint8List");
  }
}

String dynamicToHex(dynamic value) {
  switch (value.runtimeType.toString()) {
    case 'List<int>':
      return hex.encode(dynamicToUint8List(value));
    case 'Uint8List':
      return hex.encode(value);
    case 'String':
      return value;
    default:
      throw Exception("value must be String, List<int> or Uint8List");
  }
}
