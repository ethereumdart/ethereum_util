import 'dart:typed_data';

import 'package:pointycastle/pointycastle.dart';

import 'package:ethereum_util/src/utils/bytes.dart' as bytes;
import 'package:ethereum_util/src/rlp.dart' as Rlp;

/// Creates Keccak hash of the input
Uint8List keccak(dynamic a, {int bits: 256}) {
  a = bytes.toBuffer(a);
  Digest sha3 = new Digest('Keccak/$bits');
  return sha3.process(a);
}

/// Creates Keccak-256 hash of the input, alias for keccak(a, 256).
Uint8List keccak256(dynamic a) {
  return keccak(a);
}

/// Creates SHA256 hash of the input.
Uint8List sha256(dynamic a) {
  a = bytes.toBuffer(a);
  Digest sha256 = new Digest('SHA-256');
  return sha256.process(a);
}

/// Creates RIPEMD160 hash of the input.
Uint8List ripemd160(dynamic a, {bool padded: false}) {
  a = bytes.toBuffer(a);
  Digest rmd160 = new Digest('RIPEMD-160');
  var hash = rmd160.process(a);
  if (padded) return bytes.setLength(hash, 32);

  return hash;
}

/// Creates SHA-3 hash of the RLP encoded version of the input.
Uint8List rlphash(dynamic a) {
  return keccak(Rlp.encode(a));
}
