import 'dart:convert' show utf8;
import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:convert/convert.dart' show hex;

import 'package:ethereum_util/src/utils/bigint.dart';
import 'package:ethereum_util/src/utils/bytes.dart';
import 'package:ethereum_util/src/utils/hash.dart';
import 'package:ethereum_util/src/utils/utils.dart' as utils;

Uint8List eventID(String name, List<String> types) {
  String sig = '$name(${types.map(elementaryName).join(',')})';
  return keccak(toBuffer(sig));
}

Uint8List methodID(String name, List<String> types) {
  return eventID(name, types).sublist(0, 4);
}

Uint8List rawEncode(List<String> types, values) {
  var output = BytesBuffer();
  var data = BytesBuffer();

  num headLength = 0;

  types.forEach((type) {
    if (isArray(type)) {
      var size = parseTypeArray(type);

      if (size != 'dynamic') {
        headLength += 32 * size;
      } else {
        headLength += 32;
      }
    } else {
      headLength += 32;
    }
  });

  for (var i = 0; i < types.length; i++) {
    var type = elementaryName(types[i]);
    var value = values[i];
    var cur = encodeSingle(type, value);

    // Use the head/tail method for storing dynamic data
    if (isDynamic(type)) {
      output.add(encodeSingle('uint256', headLength));
      data.add(cur);
      headLength += cur.length;
    } else {
      output.add(cur);
    }
  }

  output.add(data.toBytes());
  return output.toBytes();
}

Uint8List encodeSingle(String type, dynamic arg) {
  var size;

  if (type == 'address') return encodeSingle('uint160', parseNumber(arg));
  if (type == 'string') return encodeSingle('bytes', utf8.encode(arg));

  if (type == 'bool') {
    int val = -1;
    if (arg is int) {
      val = arg == 0 ? 0 : 1;
    } else if (arg is bool) {
      val = arg ? 1 : 0;
    } else if (arg is String) {
      val = arg.isEmpty ? 0 : 1;
    }
    return encodeSingle('uint8', val);
  }

  if (isArray(type)) {
    // this part handles fixed-length ([2]) and variable length ([]) arrays. NOTE: we catch here all calls to arrays, that simplifies the rest
    if (!(arg is List)) throw new ArgumentError('Not an array?');

    size = parseTypeArray(type);
    if (size != 'dynamic' && size != 0 && arg.length > size) throw new ArgumentError('Elements exceed array size: $size');

    var ret = BytesBuffer();
    type = type.substring(0, type.lastIndexOf('['));

    if (size == 'dynamic') {
      var length = encodeSingle('uint256', arg.length);
      ret.add(length);
    }
    arg.forEach((v) => ret.add(encodeSingle(type, v)));
    return ret.toBytes();
  }

  if (type == 'bytes') {
    Uint8List argBuf = toBuffer(arg);

    var ret = BytesBuffer();
    ret.add(encodeSingle('uint256', argBuf.length));
    ret.add(argBuf);

    if ((argBuf.length % 32) != 0) ret.add(zeros(32 - (argBuf.length % 32)));

    return ret.toBytes();
  }

  if (type.startsWith('bytes')) {
    size = parseTypeN(type);
    if (size < 1 || size > 32) throw new ArgumentError('Invalid bytes<N> width: $size');

    return setLengthRight(toBuffer(arg), 32);
  }

  if (type.startsWith('uint')) {
    size = parseTypeN(type);
    if (size % 8 > 0 || size < 8 || size > 256) throw new ArgumentError('Invalid uint<N> width: $size');

    var num = parseNumber(arg);
    if (num.bitLength > size) throw new ArgumentError('Supplied uint exceeds width: $size vs ${num.bitLength}');
    if (num < BigInt.zero) throw new ArgumentError('Supplied uint is negative');

    return encodeBigInt(num, length: 32);
  }

  if (type.startsWith('int')) {
    size = parseTypeN(type);
    if (size % 8 != 0 || size < 8 || size > 256) throw new ArgumentError('Invalid int<N> width: $size');

    var num = parseNumber(arg);
    if (num.bitLength > size) throw new ArgumentError('Supplied int exceeds width: $size vs ${num.bitLength}');

    return encodeBigInt(num.toUnsigned(256), length: 32);
  }

  if (type.startsWith('ufixed')) {
    size = parseTypeNxM(type);

    var num = parseNumber(arg);

    if (num < BigInt.zero) throw new ArgumentError('Supplied ufixed is negative');

    return encodeSingle('uint256', num * BigInt.two.pow(size[1]));
  }

  if (type.startsWith('fixed')) {
    size = parseTypeNxM(type);

    return encodeSingle('int256', parseNumber(arg) * BigInt.two.pow(size[1]));
  }

  throw new ArgumentError('Unsupported or invalid type: $type');
}

String elementaryName(String name) {
  if (name.startsWith('int[')) return 'int256' + name.substring(3);
  if (name == 'int') return 'int256';
  if (name.startsWith('uint[')) return 'uint256' + name.substring(4);
  if (name == 'uint') return 'uint256';
  if (name.startsWith('fixed[')) return 'fixed128x128' + name.substring(5);
  if (name == 'fixed') return 'fixed128x128';
  if (name.startsWith('ufixed[')) return 'ufixed128x128' + name.substring(6);
  if (name == 'ufixed') return 'ufixed128x128';

  return name;
}

/// Parse N from type<N>
int parseTypeN(String type) {
  return int.parse(RegExp(r'^\D+(\d+)$').firstMatch(type)!.group(1)!, radix: 10);
}

/// Parse N,M from type<N>x<M>
List<int> parseTypeNxM(String type) {
  var tmp = RegExp(r'^\D+(\d+)x(\d+)$').firstMatch(type);
  return [
    int.parse(tmp!.group(1)!, radix: 10),
    int.parse(tmp.group(2)!, radix: 10)
  ];
}

/// Parse N in type[<N>] where "type" can itself be an array type.
dynamic parseTypeArray(String type) {
  var tmp = RegExp(r'(.*)\[(.*?)\]$').firstMatch(type);
  if (tmp != null) return tmp.group(2) == '' ? 'dynamic' : int.parse(tmp.group(2)!, radix: 10);

  return null;
}

BigInt parseNumber(dynamic arg) {
  if (arg is String) {
    if (utils.isHexPrefixed(arg)) return decodeBigInt(hex.decode(utils.stripHexPrefix(arg)));

    return BigInt.parse(arg, radix: 10);
  }

  if (arg is int) return BigInt.from(arg);
  if (arg is BigInt) return arg;

  throw new ArgumentError('Argument is not a number');
}

bool isArray(String type) {
  return type.lastIndexOf(']') == type.length - 1;
}

/// Is a type dynamic?
bool isDynamic(String type) {
  return type == 'string' || type == 'bytes' || parseTypeArray(type) == 'dynamic';
}
