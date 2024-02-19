import 'dart:typed_data';

import 'package:convert/convert.dart' show hex;

import 'hex.dart';

BigInt u8aToBn(
  Uint8List u8a, {
  Endian endian = Endian.little,
  bool isNegative = false,
}) {
  return hexToBn('0x' + hex.encode(u8a),
      endian: endian, isNegative: isNegative);
}

var _byteMask = new BigInt.from(0xff);
Uint8List bnToU8a(BigInt number) {
  // Not handling negative numbers. Decide how you want to do that.
  int size = (number.bitLength + 7) >> 3;
  var result = new Uint8List(size);
  for (int i = 0; i < size; i++) {
    result[size - i - 1] = (number & _byteMask).toInt();
    number = number >> 8;
  }
  final List<int> list = List.from(result);
  return Uint8List.fromList(list.reversed.toList());
}
