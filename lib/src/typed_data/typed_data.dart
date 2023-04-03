import 'dart:typed_data';

import 'package:convert/convert.dart';

import 'package:ethereum_util/src/typed_data/constants.dart';
import 'package:ethereum_util/src/typed_data/signature.dart';
import 'package:ethereum_util/src/typed_data/util.dart';
import 'package:ethereum_util/src/utils/bytes.dart';
import 'package:ethereum_util/src/utils/utils.dart';


/// Sign typed data, support all versions
///
/// @param {String|Uint8List} private key - wallet's private key
/// @param {String} jsonData - raw json of typed data
/// @param {TypedDataVersion} version - typed data sign method version
/// @returns {String} - signature
String signTypedData({required Uint8List privateKey, required String jsonData, required TypedDataVersion version}) {
    return SignatureUtil.sign(
      message: TypedDataUtil.hashMessage(jsonData: jsonData, version: version),
      privateKey: privateKey
    );
  }

String signTypedDataCompact({required Uint8List privateKey, required String jsonData, required TypedDataVersion version}) {
  return SignatureUtil.signToCompact(
    message: TypedDataUtil.hashMessage(jsonData: jsonData, version: version),
    privateKey: privateKey
  );
}

  String concatSig(Uint8List r, Uint8List s, Uint8List v) {
    var rSig = fromSigned(r);
    var sSig = fromSigned(s);
    var vSig = bufferToInt(v);
    var rStr = _padWithZeroes(hex.encode(toUnsigned(rSig)), 64);
    var sStr = _padWithZeroes(hex.encode(toUnsigned(sSig)), 64);
    var vStr = stripHexPrefix(intToHex(vSig));
    return addHexPrefix(rStr + sStr + vStr);
  }

  String _padWithZeroes(String number, int length) {
    var myString = '' + number;
    while (myString.length < length) {
      myString = '0' + myString;
    }
    return myString;
  }