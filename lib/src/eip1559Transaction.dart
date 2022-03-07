import 'dart:core';
import 'dart:typed_data';

import 'package:convert/convert.dart';

import 'package:ethereum_util/src/hash.dart';
import 'package:ethereum_util/src/rlp.dart' as Rlp;
import 'package:ethereum_util/src/signature.dart' as signature;
import 'package:ethereum_util/src/transaction.dart';
import 'package:ethereum_util/src/utils.dart';

int TRANSACTION_TYPE = 2;
Uint8List TRANSACTION_TYPE_BUFFER = Uint8List.fromList(hex.decode(TRANSACTION_TYPE.toRadixString(16).padLeft(2, '0')));

class Eip1559Transaction {
  TxData data;
  TxNetwork network;

  Eip1559Transaction(this.data, this.network);

  List raw() {
    return [
      intToBuffer(this.network.chainId),
      intToBuffer(this.data.nonce),
      intToBuffer(this.data.maxPriorityFeePerGas),
      intToBuffer(this.data.maxFeePerGas),
      intToBuffer(this.data.gasLimit),
      stringToBuffer(this.data.to),
      intToBuffer(this.data.value),
      stringToBuffer(this.data.data),
      [],
      this.data.v == null ? [] : intToBuffer(this.data.v),
      this.data.r == null ? [] : intToBuffer(this.data.r),
      this.data.s == null ? [] : intToBuffer(this.data.s)
    ];
  }

  /// Returns the serialized unsigned tx (hashed or raw), which can be used.
  /// Return hashed message if [hashMsg] set to true.
  List<int> getMessageToSign({bool hashMsg = true}) {
    List base = this.raw().sublist(0, 9);
    var msg = TRANSACTION_TYPE_BUFFER + Rlp.encode(base);

    if (hashMsg) return keccak256(msg);

    return msg;
  }

  /// Returns the serialized encoding of the EIP-1559 transaction.
  serialize() {
    List base = this.raw();
    return TRANSACTION_TYPE_BUFFER + Rlp.encode(base);
  }

  /// Sign the tx message with [privateKey].
  sign(Uint8List privateKey) {
    var msg = this.getMessageToSign();
    signature.ECDSASignature result = signature.sign(Uint8List.fromList(msg), privateKey);

    this.data.v = result.v - 27;
    this.data.r = result.r;
    this.data.s = result.s;

    return this.serialize();
  }
}
