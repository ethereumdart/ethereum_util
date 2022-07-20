import 'dart:core';
import 'dart:typed_data';

import 'package:ethereum_util/src/hash.dart';
import 'package:ethereum_util/src/rlp.dart' as Rlp;
import 'package:ethereum_util/src/signature.dart' as signature;
import 'package:ethereum_util/src/transaction.dart';
import 'package:ethereum_util/src/utils.dart';

class LegacyTransaction {
  TxData data;
  TxNetwork network;

  LegacyTransaction(this.data, this.network);

  List raw() {
    return [
      intToBuffer(this.data.nonce),
      intToBuffer(this.data.gasPrice),
      intToBuffer(this.data.gasLimit),
      stringToBuffer(this.data.to),
      intToBuffer(this.data.value),
      stringToBuffer(this.data.data),
      this.data.v == null ? Uint8List.fromList([]) : intToBuffer(this.data.v),
      this.data.r == null ? Uint8List.fromList([]) : intToBuffer(this.data.r),
      this.data.s == null ? Uint8List.fromList([]) : intToBuffer(this.data.s)
    ];
  }

  /// Returns the serialized unsigned tx (hashed or raw), which can be used.
  /// Return hashed message if [hashMsg] set to true.
  List<int> getMessageToSign() {
    var base = this.raw().sublist(0, 6);
    base.addAll([
      intToBuffer(network.chainId),
      Uint8List.fromList([]),
      Uint8List.fromList([])
    ]);

    return rlphash(base);
  }

  /// Returns the serialized encoding of the legacy transaction.
  serialize() {
    return Rlp.encode(this.raw());
  }

  /// Sign the tx message with [privateKey].
  sign(Uint8List privateKey) {
    var msg = this.getMessageToSign();
    signature.ECDSASignature result = signature.sign(Uint8List.fromList(msg), privateKey);

    this.data.v = result.v + network.chainId * 2 + 8;
    this.data.r = result.r;
    this.data.s = result.s;

    return this.serialize();
  }
}
