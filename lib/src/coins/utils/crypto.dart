import 'package:bip39/bip39.dart' as bip39;
import 'package:bip32/bip32.dart' as bip32;
import 'package:convert/convert.dart' show hex;
import 'package:pinenacl/ed25519.dart';

Uint8List mnemonicToSeed(String mnemonic) {
  return bip39.mnemonicToSeed(mnemonic);
}

Future<Uint8List> derivePath(Uint8List seed, String path) async {
  final keyChain = bip32.BIP32.fromSeed(seed);
  final keyPair = keyChain.derivePath(path);
  return Uint8List.fromList(keyPair.privateKey!);
}

Future<Uint8List> mnemonicToPrivateKey(String mnemonic, String path) async {
  final seed = mnemonicToSeed(mnemonic);
  final privateKey = await derivePath(seed, path);
  return Uint8List.fromList(privateKey);
}

Uint8List dynamicToUint8List(dynamic value) {
  if (value is String) {
    return Uint8List.fromList(hex.decode(value));
  } else if (value is Uint8List) {
    return value;
  } else {
    throw Error();
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
