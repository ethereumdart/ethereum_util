import 'dart:typed_data';

import 'package:ethereum_util/src/bytes.dart' as bytes;
import 'package:ethereum_util/src/rlp.dart' as Rlp;
import 'package:pointycastle/pointycastle.dart';

/**
 * Creates Keccak hash of the input
 * @param a The input data (Buffer|Array|String|Number)
 * @param bits The Keccak width
 */
Uint8List keccak(a, {int bits: 256}) {
  a = bytes.toBuffer(a);
  Digest sha3 = new Digest("SHA-3/${bits}");
  return sha3.process(a);
}

/**
 * Creates Keccak-256 hash of the input, alias for keccak(a, 256).
 * @param a The input data (Buffer|Array|String|Number)
 */
Uint8List keccak256(a) {
  return keccak(a);
}

/**
 * Creates SHA256 hash of the input.
 * @param a The input data (Buffer|Array|String|Number)
 */
Uint8List sha256(a) {
  a = bytes.toBuffer(a);
  Digest sha256 = new Digest("SHA-256");
  return sha256.process(a);
}

/**
 * Creates RIPEMD160 hash of the input.
 * @param a The input data (Buffer|Array|String|Number)
 * @param padded Whether it should be padded to 256 bits or not
 */
Uint8List ripemd160(a, {bool padded: false}) {
  a = bytes.toBuffer(a);
  Digest rmd160 = new Digest('RIPEMD-160');
  var hash = rmd160.process(a);
  if (padded) {
    return bytes.setLength(hash, 32);
  } else {
    return hash;
  }
}

/**
 * Creates SHA-3 hash of the RLP encoded version of the input.
 * @param a The input data
 */
Uint8List rlphash(dynamic a) {
  a = bytes.toBuffer(a);
  return keccak(Rlp.encode(a));
}
