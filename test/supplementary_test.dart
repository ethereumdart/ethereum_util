import 'dart:math';
import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:ethereum_util/src/random.dart';
import 'package:ethereum_util/src/rlp.dart' as rlp;

void main() {
  group('random', () {
    DartRandom random = new DartRandom(new Random());
    test('get algorithmName', () {
      expect('DartRandom', random.algorithmName);
    });

    test('random next unit', () {
      random.nextUint16();
      random.nextUint32();
    });
  });

  group('rlp', () {
    test('decode error', () {
      Uint8List input = new Uint8List(16);
      input[0] = 0xf8;
      input[1] = 0xf8;
      try {
        rlp.decode(input, true);
      } catch (error) {
        expect(error.toString(),
            'FormatException: invalid rlp: total length is larger than the data');
      }
    });
  });
}
