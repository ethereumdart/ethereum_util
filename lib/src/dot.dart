import 'dart:typed_data';

import 'package:substrate_bip39/substrate_bip39.dart';
import 'package:convert/convert.dart' show hex;
import 'package:ss58/ss58.dart';
import 'package:sr25519/sr25519.dart';
// import 'package:merlin/merlin.dart' as merlin;

/// Generates Sui seed by mnemonic
Future<Uint8List> mnemonicToPrivateKey(String mnemonic) async {
  final seed = await SubstrateBip39.ed25519.seedFromUri(mnemonic);
  return Uint8List.fromList(seed);
}

/// Generates new Pair key by privateKey
Uint8List privateKeyToPublicKey(Uint8List privateKey) {
  final MiniSecretKey priv = MiniSecretKey.fromHex(hex.encode(privateKey));
  final PublicKey pub = priv.public();
  final publicBytes = pub.encode();
  return Uint8List.fromList(publicBytes);
}

// /// Constructs the dot address associated with given public key
String publicKeyToAddress(Uint8List publicKey, {prefix = 0}) {
  return Address(prefix: prefix, pubkey: publicKey).encode();
}

/// Generates the dot address associated with mnemonic
Future<String> mnemonicToAddress(String mnemonic, {prefix = 0}) async {
  final privateKey = await mnemonicToPrivateKey(mnemonic);
  final publicKey = privateKeyToPublicKey(privateKey);
  return publicKeyToAddress(publicKey);
}

// String signature(Uint8List message, Uint8List privateKey) {
//   final MiniSecretKey priv = MiniSecretKey.fromHex(hex.encode(privateKey));
//   var sk = priv.expandEd25519();
//   // sk = priv.expandUniform();
//   final merlin.Transcript transcript = merlin.Transcript('hello');
//   final signature = sk.sign(transcript);
//   return hex.encode(signature.encode());
// }

// bool verifySignedMessage(
//     Uint8List publicKey, String signedMessage, String message) {
//   return true;
// }
