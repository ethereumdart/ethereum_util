import 'dart:typed_data';

import 'package:convert/convert.dart' show hex;

/// The max integer that this VM can handle
final BigInt MAX_INTEGER = BigInt.parse('ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff', radix: 16);

/// 2^256
final BigInt TWO_POW256 = BigInt.parse('10000000000000000000000000000000000000000000000000000000000000000', radix: 16);

/// Keccak-256 hash of null
final String KECCAK256_NULL_S = 'c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470';

/// Keccak-256 hash of null
final Uint8List KECCAK256_NULL = Uint8List.fromList(hex.decode(KECCAK256_NULL_S));

/// Keccak-256 of an RLP of an empty array
final String KECCAK256_RLP_ARRAY_S = '1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347';

/// Keccak-256 of an RLP of an empty array
final Uint8List KECCAK256_RLP_ARRAY = Uint8List.fromList(hex.decode(KECCAK256_RLP_ARRAY_S));

/// Keccak-256 hash of the RLP of null
final String KECCAK256_RLP_S = '56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421';

/// Keccak-256 hash of the RLP of null
final Uint8List KECCAK256_RLP = Uint8List.fromList(hex.decode(KECCAK256_RLP_S));
