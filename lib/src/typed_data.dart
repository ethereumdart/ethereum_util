import 'dart:convert';
import 'dart:typed_data';

import 'package:buffer/buffer.dart';
import 'package:convert/convert.dart';
import 'package:ethereum_util/src/abi.dart' as ethAbi;
import 'package:ethereum_util/src/bytes.dart';
import 'package:ethereum_util/src/signature.dart';
import 'package:ethereum_util/src/utils.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_schema/json_schema.dart';
import 'package:meta/meta.dart';

part 'typed_data.g.dart';

/// Returns a continuous, hex-prefixed hex value for the signature,
/// suitable for inclusion in a JSON transaction's data field.
String concatSig(Uint8List r, Uint8List s, Uint8List v) {
  var rSig = fromSigned(r);
  var sSig = fromSigned(s);
  var vSig = bufferToInt(v);
  var rStr = _padWithZeroes(hex.encode(toUnsigned(rSig)), 64);
  var sStr = _padWithZeroes(hex.encode(toUnsigned(sSig)), 64);
  var vStr = stripHexPrefix(intToHex(vSig));
  return addHexPrefix(rStr + sStr + vStr);
}

String signTypedData(Uint8List privateKey, MsgParams msgParams) {
  var message = TypedDataUtils.sign(msgParams.data);
  var sig = sign(message, privateKey);
  return concatSig(toBuffer(sig.r), toBuffer(sig.s), toBuffer(sig.v));
}

/// Return address of a signer that did signTypedData.
/// Expects the same data that were used for signing. sig is a prefixed signature.
String recoverTypedSignature(MsgParams msgParams) {
  var publicKey = msgParams.recoverPublicKey();
  var sender = publicKeyToAddress(publicKey);
  return bufferToHex(sender);
}

String _padWithZeroes(String number, int length) {
  var myString = '' + number;
  while (myString.length < length) {
    myString = '0' + myString;
  }
  return myString;
}

String normalize(dynamic input) {
  if (input == null) {
    return null;
  }

  if (!(input is String) && !(input is int)) {
    throw ArgumentError("input must be String or int");
  }

  if (input is int) {
    var buffer = toBuffer(input);
    input = bufferToHex(buffer);
  }

  return addHexPrefix(input.toLowerCase());
}

class MsgParams {
  TypedData data;
  String sig;

  MsgParams({this.data, this.sig});

  Uint8List recoverPublicKey() {
    var sigParams = fromRpcSig(sig);
    return recoverPublicKeyFromSignature(
        ECDSASignature(sigParams.r, sigParams.s, sigParams.v),
        TypedDataUtils.sign(data));
  }
}

@JsonSerializable(nullable: true)
class TypedData {
  Map<String, List<TypedDataField>> types;
  String primaryType;
  EIP712Domain domain;
  Map<String, dynamic> message;

  TypedData({this.types, this.primaryType, this.domain, this.message});

  factory TypedData.fromJson(Map<String, dynamic> json) =>
      _$TypedDataFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TypedDataToJson(this);
}

@JsonSerializable(nullable: true)
class TypedDataField {
  String name;
  String type;

  TypedDataField({@required this.name, @required this.type});

  factory TypedDataField.fromJson(Map<String, dynamic> json) =>
      _$TypedDataFieldFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$TypedDataFieldToJson(this);
}

@JsonSerializable(nullable: true)
class EIP712Domain {
  String name;
  String version;
  int chainId;
  String verifyingContract;

  EIP712Domain({this.name, this.version, this.chainId, this.verifyingContract});

  dynamic operator [](String key) {
    switch (key) {
      case 'name':
        return name;
      case 'version':
        return version;
      case 'chainId':
        return chainId;
      case 'verifyingContract':
        return verifyingContract;
      default:
        throw ArgumentError("Key ${key} is invalid");
    }
  }

  factory EIP712Domain.fromJson(Map<String, dynamic> json) =>
      _$EIP712DomainFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$EIP712DomainToJson(this);
}

class TypedDataUtils {
  static Uint8List sign(TypedData typedData) {
    var parts = BytesBuffer();
    parts.add(hex.decode('1901'));
    parts.add(hashStruct('EIP712Domain', typedData.domain, typedData.types));
    parts.add(
        hashStruct(typedData.primaryType, typedData.message, typedData.types));
    return sha3(parts.toBytes());
  }

  static Uint8List hashStruct(String primaryType, dynamic data,
      Map<String, List<TypedDataField>> types) {
    return sha3(encodeData(primaryType, data, types));
  }

  /// Hashes the type of an object
  static Uint8List hashType(String primaryType, dynamic types) {
    return sha3(
        Uint8List.fromList(utf8.encode(encodeType(primaryType, types))));
  }

  static Uint8List encodeData(String primaryType, dynamic data,
      Map<String, List<TypedDataField>> types) {
    if (!(data is Map<String, dynamic>) && !(data is EIP712Domain)) {
      throw ArgumentError("Unsupported data type");
    }

    var encodedTypes = List<String>();
    encodedTypes.add('bytes32');
    var encodedValues = List<dynamic>();
    encodedValues.add(hashType(primaryType, types));

    types[primaryType].forEach((TypedDataField field) {
      var value = data[field.name];
      if (value != null) {
        if (field.type == 'bytes') {
          encodedTypes.add('bytes32');
          value = sha3(value);
          encodedValues.add(value);
        } else if (field.type == 'string') {
          encodedTypes.add('bytes32');
          // convert string to buffer - prevents ethUtil from interpreting strings like '0xabcd' as hex
          if (value is String) {
            value = Uint8List.fromList(utf8.encode(value));
          }
          value = sha3(value);
          encodedValues.add(value);
        } else if (types[field.type] != null) {
          encodedTypes.add('bytes32');
          value = sha3(encodeData(field.type, value, types));
          encodedValues.add(value);
        } else if (field.type.lastIndexOf(']') == field.type.length - 1) {
          throw new ArgumentError(
              'Arrays currently unimplemented in encodeData');
        } else {
          encodedTypes.add(field.type);
          encodedValues.add(value);
        }
      }
    });

    return ethAbi.rawEncode(encodedTypes, encodedValues);
  }

  /// Encodes the type of an object by encoding a comma delimited list of its members
  static String encodeType(
      String primaryType, Map<String, List<TypedDataField>> types) {
    var result = '';
    var deps = findTypeDependencies(primaryType, types);
    deps = deps.where((dep) => dep != primaryType).toList();
    deps.sort();
    deps.insert(0, primaryType);
    deps.forEach((dep) {
      if (!types.containsKey(dep)) {
        throw new ArgumentError('No type definition specified: ' + dep);
      }
      result += dep +
          '(' +
          types[dep].map((field) => field.type + ' ' + field.name).join(',') +
          ')';
    });
    return result;
  }

  /**
   * Finds all types within a type defintion object
   *
   * @param {string} primaryType - Root type
   * @param {Object} types - Type definitions
   * @param {Array} results - current set of accumulated types
   * @returns {Array} - Set of all types found in the type definition
   */
  static List<String> findTypeDependencies(
      String primaryType, Map<String, List<TypedDataField>> types,
      {List<String> results}) {
    if (results == null) {
      results = List();
    }
    if (results.indexOf(primaryType) >= 0 || !types.containsKey(primaryType)) {
      return results;
    }
    results.add(primaryType);
    types[primaryType].forEach((TypedDataField field) {
      findTypeDependencies(field.type, types, results: results).forEach((dep) {
        if (results.indexOf(dep) == -1) {
          results.add(dep);
        }
      });
    });
    return results;
  }
}

final JsonSchema TYPED_MESSAGE_SCHEMA = JsonSchema.createSchema(r'''
{
  "type": "object",
  "properties": {
    "types": {
      "type": "object",
      "additionalProperties": {
        "type": "array",
        "items": {
          "type": "object",
          "properties": {"name": {"type": "string"}, "type": {"type": "string"}},
          "required": ["name", "type"
          ]
        }
      }
    },
    "primaryType": {"type": "string"},
    "domain": {"type": "object"},
    "message": {"type": "object"}
  },
  "required": ["types", "primaryType", "domain", "message"]
}
''');
