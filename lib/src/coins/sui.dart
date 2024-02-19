import 'package:bip39/bip39.dart' as bip39;
import "package:ed25519_hd_key/ed25519_hd_key.dart";
import 'package:pointycastle/digests/blake2b.dart';
import 'package:pinenacl/ed25519.dart';
import 'package:convert/convert.dart' show hex;

const SUI_ADDRESS_LENGTH = 32;

/// Generates Sui seed by mnemonic
Future<Uint8List> mnemonicToSuiSeedByte(String mnemonic) async {
  final seed = bip39.mnemonicToSeed(mnemonic);
  final path = "m/44'/784'/0'/0'/0'";
  final seedNum = await ED25519_HD_KEY.derivePath(path, seed);
  return Uint8List.fromList(seedNum.key);
}

/// Generates new Pair key by privateKey
SigningKey generateNewPairKeyBySeed(Uint8List privateKey) {
  return SigningKey.fromSeed(privateKey);
}

/// Generates new Pair key by mnemonic
Future<SigningKey> generateSuiPairKey(String mnemonic) async {
  final seed = await mnemonicToSuiSeedByte(mnemonic);
  return generateNewPairKeyBySeed(seed);
}

/// Constructs public key to Black2bHash
String publicKeyToBlack2bHash(AsymmetricPublicKey publicKey) {
  final suiBytes = new Uint8List(publicKey.length + 1);
  suiBytes[0] = 0;
  suiBytes.setRange(1, suiBytes.length, publicKey);
  final digest = Blake2bDigest(digestSize: 32);
  digest.update(suiBytes, 0, suiBytes.length);
  final hash = Uint8List(digest.digestSize);
  digest.doFinal(hash, 0);
  final hexes =
      List<String>.generate(256, (i) => i.toRadixString(16).padLeft(2, '0'));
  String _hex = '';
  for (int i = 0; i < hash.length; i++) {
    _hex += hexes[hash[i]];
  }
  return _hex;
}

/// Constructs the Sui address associated with given public key
String publicKeyToSuiAddress(AsymmetricPublicKey publicKey) {
  final hash = publicKeyToBlack2bHash(publicKey);
  final slicedHash = hash.substring(0, SUI_ADDRESS_LENGTH * 2);
  return '0x${slicedHash.toLowerCase().padLeft(SUI_ADDRESS_LENGTH * 2, '0')}';
}

/// Generates the sui address associated with mnemonic
Future<String> mnemonicToSuiAddress(String mnemonic) async {
  final signature = await generateSuiPairKey(mnemonic);
  return publicKeyToSuiAddress(signature.publicKey);
}

/// pure Ed25519 signature
String suiSignatureFromSeed(Uint8List message, Uint8List privateKey) {
  SigningKey signingKey = generateNewPairKeyBySeed(privateKey);
  SignedMessage signedMessage = signingKey.sign(message);
  return hex.encode(signedMessage.signature);
}

SignedMessage suiSignatureFromSeedReturnRaw(
    Uint8List message, Uint8List privateKey) {
  SigningKey signingKey = generateNewPairKeyBySeed(privateKey);
  return signingKey.sign(message);
}

bool suiVerifySignedMessage(Uint8List publicKey, SignedMessage signedMessage) {
  VerifyKey verifyKey = new VerifyKey(Uint8List.fromList(publicKey));
  return verifyKey.verify(
      signature: signedMessage.signature,
      message: Uint8List.fromList(signedMessage.message));
}
