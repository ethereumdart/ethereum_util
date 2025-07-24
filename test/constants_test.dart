import 'package:convert/convert.dart' show hex;
import 'package:test/test.dart';

import 'package:ethereum_util/src/constants.dart';

void main() {
  group('constants', () {
    test('should match constants', () {
      expect(MAX_INTEGER.toRadixString(16), 'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
      expect(TWO_POW256.toRadixString(16), '10000000000000000000000000000000000000000000000000000000000000000');
      expect(KECCAK256_NULL_S, 'c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470');
      expect(hex.encode(KECCAK256_NULL), 'c5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470');
      expect(KECCAK256_RLP_ARRAY_S, '1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347');
      expect(hex.encode(KECCAK256_RLP_ARRAY), '1dcc4de8dec75d7aab85b567b6ccd41ad312451b948a7413f0a142fd40d49347');
      expect(KECCAK256_RLP_S, '56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421');
      expect(hex.encode(KECCAK256_RLP), '56e81f171bcc55a6ff8345e692c0f86e5b48e01b996cadc001622fb5e363b421');
    });
  });
}
