import 'dart:convert' show jsonDecode, utf8;
import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:convert/convert.dart' show hex;
import 'package:ethereum_util/src/bigint.dart';
import 'package:ethereum_util/src/bytes.dart';
import 'package:ethereum_util/src/hash.dart';
import 'package:ethereum_util/src/utils.dart' as utils;

Uint8List eventID(String name, List<String> types) {
  // FIXME: use node.js util.format?
  var sig = name + '(' + types.map(elementaryName).join(',') + ')';
  return keccak(toBuffer(sig));
}

Uint8List methodID(String name, List<String> types) {
  return eventID(name, types).sublist(0, 4);
}

Uint8List rawEncode(List<String> types, values) {
  var output = BytesBuffer();
  var data = BytesBuffer();

  var headLength = 0;

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
  var size, i;

  if (type == 'address') {
    return encodeSingle('uint160', parseNumber(arg));
  } else if (type == 'bool') {
    int val;
    if (arg is int) {
      val = arg == 0 ? 0 : 1;
    } else if (arg is bool) {
      val = arg ? 1 : 0;
    } else if (arg is String) {
      val = arg.isEmpty ? 0 : 1;
    }
    return encodeSingle('uint8', val);
  } else if (type == 'string') {
    return encodeSingle('bytes', utf8.encode(arg));
  } else if (isArray(type)) {
    // this part handles fixed-length ([2]) and variable length ([]) arrays
    // NOTE: we catch here all calls to arrays, that simplifies the rest
    if (!(arg is List)) {
      throw new ArgumentError('Not an array?');
    }
    size = parseTypeArray(type);
    if (size != 'dynamic' && size != 0 && arg.length > size) {
      throw new ArgumentError('Elements exceed array size: ${size}');
    }
    var ret = BytesBuffer();
    type = type.substring(0, type.lastIndexOf('['));
    if (arg is String) {
      arg = jsonDecode(arg);
    }

    if (size == 'dynamic') {
      var length = encodeSingle('uint256', arg.length);
      ret.add(length);
    }
    arg.forEach((v) {
      ret.add(encodeSingle(type, v));
    });
    return ret.toBytes();
  } else if (type == 'bytes') {
    arg = toBuffer(arg);

    var ret = BytesBuffer();
    ret.add(encodeSingle('uint256', arg.length));
    ret.add(arg);

    if ((arg.length % 32) != 0) {
      ret.add(zeros(32 - (arg.length % 32)));
    }

    return ret.toBytes();
  } else if (type.startsWith('bytes')) {
    size = parseTypeN(type);
    if (size < 1 || size > 32) {
      throw new ArgumentError('Invalid bytes<N> width: ${size}');
    }

    return setLengthRight(toBuffer(arg), 32);
  } else if (type.startsWith('uint')) {
    size = parseTypeN(type);
    if ((size % 8 > 0) || (size < 8) || (size > 256)) {
      throw new ArgumentError('Invalid uint<N> width: ${size}');
    }

    var num = parseNumber(arg);
    if (num.bitLength > size) {
      throw new ArgumentError(
          'Supplied uint exceeds width: ${size} vs ${num.bitLength}');
    }

    if (num < BigInt.zero) {
      throw new ArgumentError('Supplied uint is negative');
    }

    return encodeBigInt(num, length: 32);
  } else if (type.startsWith('int')) {
    size = parseTypeN(type);
    if ((size % 8 != 0) || (size < 8) || (size > 256)) {
      throw new ArgumentError('Invalid int<N> width: ${size}');
    }

    var num = parseNumber(arg);
    if (num.bitLength > size) {
      throw new ArgumentError(
          'Supplied int exceeds width: ${size} vs ${num.bitLength}');
    }

    return encodeBigInt(num.toUnsigned(256), length: 32);
  } else if (type.startsWith('ufixed')) {
    size = parseTypeNxM(type);

    var num = parseNumber(arg);

    if (num < BigInt.zero) {
      throw new ArgumentError('Supplied ufixed is negative');
    }

    return encodeSingle('uint256', num * BigInt.two.pow(size[1]));
  } else if (type.startsWith('fixed')) {
    size = parseTypeNxM(type);

    return encodeSingle('int256', parseNumber(arg) * BigInt.two.pow(size[1]));
  }

  throw new ArgumentError('Unsupported or invalid type: ' + type);
}

String elementaryName(String name) {
  if (name.startsWith('int[')) {
    return 'int256' + name.substring(3);
  } else if (name == 'int') {
    return 'int256';
  } else if (name.startsWith('uint[')) {
    return 'uint256' + name.substring(4);
  } else if (name == 'uint') {
    return 'uint256';
  } else if (name.startsWith('fixed[')) {
    return 'fixed128x128' + name.substring(5);
  } else if (name == 'fixed') {
    return 'fixed128x128';
  } else if (name.startsWith('ufixed[')) {
    return 'ufixed128x128' + name.substring(6);
  } else if (name == 'ufixed') {
    return 'ufixed128x128';
  }
  return name;
}

/// Parse N from type<N>
int parseTypeN(String type) {
  return int.parse(RegExp(r'^\D+(\d+)$').firstMatch(type).group(1), radix: 10);
}

/// Parse N,M from type<N>x<M>
List<int> parseTypeNxM(String type) {
  var tmp = RegExp(r'^\D+(\d+)x(\d+)$').firstMatch(type);
  return [
    int.parse(tmp.group(1), radix: 10),
    int.parse(tmp.group(2), radix: 10)
  ];
}

/// Parse N in type[<N>] where "type" can itself be an array type.
dynamic parseTypeArray(String type) {
  var tmp = RegExp(r'(.*)\[(.*?)\]$').firstMatch(type);
  if (tmp != null) {
    return tmp.group(2) == '' ? 'dynamic' : int.parse(tmp.group(2), radix: 10);
  }
  return null;
}

BigInt parseNumber(dynamic arg) {
  if (arg is String) {
    if (utils.isHexPrefixed(arg)) {
      return decodeBigInt(hex.decode(utils.stripHexPrefix(arg)));
    } else {
      return BigInt.parse(arg, radix: 10);
    }
  } else if (arg is int) {
    return BigInt.from(arg);
  } else if (arg is BigInt) {
    return arg;
  } else {
    throw new ArgumentError('Argument is not a number');
  }
}

bool isArray(String type) {
  return type.lastIndexOf(']') == type.length - 1;
}

/// Is a type dynamic?
bool isDynamic(String type) {
  // FIXME: handle all types? I don't think anything is missing now
  return (type == 'string') ||
      (type == 'bytes') ||
      (parseTypeArray(type) == 'dynamic');
}
