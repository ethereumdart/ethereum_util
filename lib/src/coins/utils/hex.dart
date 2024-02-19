import 'dart:typed_data';

import 'package:convert/convert.dart';

BigInt hexToBn(
  dynamic value, {
  Endian endian = Endian.big,
  bool isNegative = false,
}) {
  if (value == null) {
    return BigInt.from(0);
  }
  if (isNegative == false) {
    final sValue = value is num
        ? int.parse(value.toString(), radix: 10).toRadixString(16)
        : value;
    if (endian == Endian.big) {
      return BigInt.parse(sValue, radix: 16);
    }
    return decodeBigInt(
      hexToBytes(sValue),
    );
  } else {
    String hex = value is num
        ? int.parse(value.toString(), radix: 10).toRadixString(16)
        : value;
    if (hex.length % 2 > 0) {
      hex = '0$hex';
    }
    hex = decodeBigInt(
      hexToBytes(hex),
      endian: endian,
    ).toRadixString(16);
    BigInt bn = BigInt.parse(hex, radix: 16);

    final result = 0x80 &
        int.parse(hex.substring(0, 2 > hex.length ? hex.length : 2), radix: 16);
    if (result > 0) {
      BigInt some = BigInt.parse(
        bn.toRadixString(2).split('').map((i) {
          return '0' == i ? 1 : 0;
        }).join(),
        radix: 2,
      );
      some += BigInt.one;
      bn = -some;
    }
    return bn;
  }
}

BigInt decodeBigInt(List<int> bytes, {Endian endian = Endian.little}) {
  BigInt result = BigInt.from(0);
  for (int i = 0; i < bytes.length; i++) {
    final newValue = BigInt.from(
      bytes[endian == Endian.little ? i : bytes.length - i - 1],
    );
    result += newValue << (8 * i);
  }
  return result;
}

Uint8List encodeBigInt(
  BigInt number, {
  Endian endian = Endian.little,
  int? bitLength,
}) {
  final bl = (bitLength != null) ? bitLength : number.bitLength;
  final int size = (bl + 7) >> 3;
  final result = Uint8List(size);

  for (int i = 0; i < size; i++) {
    result[endian == Endian.little ? i : size - i - 1] =
        (number & BigInt.from(0xff)).toInt();
    number = number >> 8;
  }
  return result;
}

String strip0xHex(String hex) {
  if (hex.startsWith('0x')) {
    return hex.substring(2);
  }
  return hex;
}

List<int> hexToBytes(String hexStr) {
  return hex.decode(strip0xHex(hexStr));
}
