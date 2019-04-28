import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:ethereum_util/src/utils.dart' show intToBuffer, isHexString, padToEven, stripHexPrefix;
import 'package:pointycastle/src/utils.dart' as p_utils;

//Copy and pasted from the rlp nodejs library, translated to dart on a
//best-effort basis.

Uint8List encode(dynamic input) {
  if (input is List && !(input is Uint8List)) {
    final output = <Uint8List>[];
    for (var data in input) {
      output.add(encode(data));
    }

    final data = _concat(output);
    return _concat([encodeLength(data.length, 192), data]);
  } else {
    final data = _toBuffer(input);

    if (data.length == 1 && data[0] < 128) {
      return data;
    } else {
      return _concat([encodeLength(data.length, 128), data]);
    }
  }
}

Uint8List encodeLength(int length, int offset) {
  if (length < 56) {
    return Uint8List.fromList([length + offset]);
  } else {
    final hexLen = _intToHex(length);
    final lLength = hexLen.length ~/ 2;

    return _concat([
      Uint8List.fromList([offset + 55 + lLength]),
      Uint8List.fromList(hex.decode(hexLen))
    ]);
  }
}

Uint8List _concat(List<Uint8List> lists) {
  final list = <int>[];

  lists.forEach(list.addAll);

  return Uint8List.fromList(list);
}

String _intToHex(int a) {
  return hex.encode(_toBuffer(a));
}

Uint8List _toBuffer(dynamic data) {
  if (data is Uint8List) return data;

  if (data is String) {
    if (isHexString(data)) {
      return Uint8List.fromList(hex.decode(padToEven(stripHexPrefix(data))));
    } else {
      return Uint8List.fromList(utf8.encode(data));
    }
  } else if (data is int) {
    if (data == 0) return Uint8List(0);

    return Uint8List.fromList(intToBuffer(data));
  } else if (data is BigInt) {
    if (data == BigInt.zero) return Uint8List(0);

    return Uint8List.fromList(p_utils.encodeBigInt(data));
  } else if (data is List<int>) {
    return Uint8List.fromList(data);
  }

  throw TypeError();
}
