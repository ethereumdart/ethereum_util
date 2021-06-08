import 'dart:typed_data';

import 'package:ethereum_util/src/bytes.dart';
import 'package:ethereum_util/src/signature.dart';

class Wallet {
  Uint8List _privKey;
  Uint8List _pubKey;

  Wallet.fromPrivateKey(Uint8List key)
      : this._privKey = key,
        this._pubKey = privateKeyToPublicKey(key);

  String getAddressString() {
    return bufferToHex(publicKeyToAddress(_pubKey));
  }

  Uint8List getPrivateKey() {
    return this._privKey;
  }
}
