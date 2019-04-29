import 'package:convert/convert.dart';
import 'package:ethereum_util/src/abi.dart' as abi;
import 'package:test/test.dart';

// Official test vectors from https://github.com/ethereum/wiki/wiki/Ethereum-Contract-ABI
void main() {
  group('official test vector 1 (encoding)', () {
    test('should equal', () {
      var a = hex.encode(abi.methodID('baz', ['uint32', 'bool'])) +
          hex.encode(abi.rawEncode(['uint32', 'bool'], [69, 1]));
      var b =
          'cdcd77c000000000000000000000000000000000000000000000000000000000000000450000000000000000000000000000000000000000000000000000000000000001';
      expect(a, b);
    });
  });

  /* // FIXME
  group('official test vector 2 (encoding)', () {
    test('should equal', () {
      var a = hex.encode(abi.methodID('bar', [ 'real128x128[2]'])) +
          hex.encode(abi.rawEncode([ 'real128x128[2]'], [ [ 2.125, 8.5]]));
      var b = '3e27986000000000000000000000000000000002400000000000000000000000000000000000000000000000000000000000000880000000000000000000000000000000';
      expect(a, b);
    });
  });
  */

  group('official test vector 3 (encoding)', () {
    test('should equal', () {
      var a = hex.encode(abi.methodID('sam', ['bytes', 'bool', 'uint256[]'])) +
          hex.encode(abi.rawEncode([
            'bytes',
            'bool',
            'uint256[]'
          ], [
            'dave',
            true,
            [1, 2, 3]
          ]));
      var b =
          'a5643bf20000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000a0000000000000000000000000000000000000000000000000000000000000000464617665000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000003';
      expect(a, b);
    });
  });

  group('official test vector 4 (encoding)', () {
    test('should equal', () {
      var a = hex.encode(
              abi.methodID('f', ['uint', 'uint32[]', 'bytes10', 'bytes'])) +
          hex.encode(abi.rawEncode([
            'uint',
            'uint32[]',
            'bytes10',
            'bytes'
          ], [
            0x123,
            [0x456, 0x789],
            '1234567890',
            'Hello, world!'
          ]));
      var b =
          '8be6524600000000000000000000000000000000000000000000000000000000000001230000000000000000000000000000000000000000000000000000000000000080313233343536373839300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000e0000000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000004560000000000000000000000000000000000000000000000000000000000000789000000000000000000000000000000000000000000000000000000000000000d48656c6c6f2c20776f726c642100000000000000000000000000000000000000';
      expect(a, b);
    });
  });

// Homebrew tests

  group('method signature', () {
    test('should work with test()', () {
      expect(hex.encode(abi.methodID('test', [])), 'f8a8fd6d');
    });
    test('should work with test(uint)', () {
      expect(hex.encode(abi.methodID('test', ['uint'])), '29e99f07');
    });
    test('should work with test(uint256)', () {
      expect(hex.encode(abi.methodID('test', ['uint256'])), '29e99f07');
    });
    test('should work with test(uint, uint)', () {
      expect(hex.encode(abi.methodID('test', ['uint', 'uint'])), 'eb8ac921');
    });
  });

  group('event signature', () {
    test('should work with test()', () {
      expect(hex.encode(abi.eventID('test', [])),
          'f8a8fd6dd9544ca87214e80c840685bd13ff4682cacb0c90821ed74b1d248926');
    });
    test('should work with test(uint)', () {
      expect(hex.encode(abi.eventID('test', ['uint'])),
          '29e99f07d14aa8d30a12fa0b0789b43183ba1bf6b4a72b95459a3e397cca10d7');
    });
    test('should work with test(uint256)', () {
      expect(hex.encode(abi.eventID('test', ['uint256'])),
          '29e99f07d14aa8d30a12fa0b0789b43183ba1bf6b4a72b95459a3e397cca10d7');
    });
    test('should work with test(uint, uint)', () {
      expect(hex.encode(abi.eventID('test', ['uint', 'uint'])),
          'eb8ac9210327650aab0044de896b150391af3be06f43d0f74c01f05633b97a70');
    });
  });

  group('encoding negative int32', () {
    test('should equal', () {
      var a = hex.encode(abi.rawEncode(['int32'], [-2]));
      var b =
          'fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe';
      expect(a, b);
    });
  });

  group('encoding negative int256', () {
    test('should equal', () {
      var a = hex.encode(abi.rawEncode([
        'int256'
      ], [
        BigInt.parse(
            '-19999999999999999999999999999999999999999999999999999999999999',
            radix: 10)
      ]));
      var b =
          'fffffffffffff38dd0f10627f5529bdb2c52d4846810af0ac000000000000001';
      expect(a, b);
    });
  });

  group('encoding string >32bytes', () {
    test('should equal', () {
      var a = hex.encode(abi.rawEncode([
        'string'
      ], [
        ' hello world hello world hello world hello world  hello world hello world hello world hello world  hello world hello world hello world hello world hello world hello world hello world hello world'
      ]));
      var b =
          '000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000c22068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64202068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c642068656c6c6f20776f726c64000000000000000000000000000000000000000000000000000000000000';
      expect(a, b);
    });
  });

  group('encoding uint32 response', () {
    test('should equal', () {
      var a = hex.encode(abi.rawEncode(['uint32'], [42]));
      var b =
          '000000000000000000000000000000000000000000000000000000000000002a';
      expect(a, b);
    });
  });

  group('encoding string response (unsupported)', () {
    test('should equal', () {
      var a = hex.encode(
          abi.rawEncode(['string'], ['a response string (unsupported)']));
      var b =
          '0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000001f6120726573706f6e736520737472696e672028756e737570706f727465642900';
      expect(a, b);
    });
  });

  group('encoding', () {
    test('should work for uint256', () {
      var a = hex.encode(abi.rawEncode(['uint256'], [1]));
      var b =
          '0000000000000000000000000000000000000000000000000000000000000001';
      expect(a, b);
    });
    test('should work for uint', () {
      var a = hex.encode(abi.rawEncode(['uint'], [1]));
      var b =
          '0000000000000000000000000000000000000000000000000000000000000001';
      expect(a, b);
    });
    test('should work for int256', () {
      var a = hex.encode(abi.rawEncode(['int256'], [-1]));
      var b =
          'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff';
      expect(a, b);
    });
    test('should work for string and uint256[2]', () {
      var a = hex.encode(abi.rawEncode([
        'string',
        'uint256[2]'
      ], [
        'foo',
        [5, 6]
      ]));
      var b =
          '0000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000500000000000000000000000000000000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000003666f6f0000000000000000000000000000000000000000000000000000000000';
      expect(a, b);
    });
  });

  group('encoding bytes33', () {
    test('should fail', () {
      expect(() => abi.rawEncode(['bytes33'], ['']), throwsArgumentError);
    });
  });

  group('encoding uint0', () {
    test('should fail', () {
      expect(() => abi.rawEncode(['uint0'], [1]), throwsArgumentError);
    });
  });

  group('encoding uint257', () {
    test('should fail', () {
      expect(() => abi.rawEncode(['uint257'], [1]), throwsArgumentError);
    });
  });

  group('encoding int0', () {
    test('should fail', () {
      expect(() => abi.rawEncode(['int0'], [1]), throwsArgumentError);
    });
  });

  group('encoding int257', () {
    test('should fail', () {
      expect(() => abi.rawEncode(['int257'], [1]), throwsArgumentError);
    });
  });

  group('encoding uint[2] with [1,2,3]', () {
    test('should fail', () {
      expect(
          () => abi.rawEncode([
                'uint[2]'
              ], [
                [1, 2, 3]
              ]),
          throwsArgumentError);
    });
  });

  group('encoding uint8 with 9bit data', () {
    test('should fail', () {
      expect(() => abi.rawEncode(['uint8'], [BigInt.one << 9]),
          throwsArgumentError);
    });
  });

  group('encoding ufixed128x128', () {
    test('should equal', () {
      var a = hex.encode(abi.rawEncode(['ufixed128x128'], [1]));
      var b =
          '0000000000000000000000000000000100000000000000000000000000000000';
      expect(a, b);
    });
  });

  group('encoding fixed128x128', () {
    test('should equal', () {
      var a = hex.encode(abi.rawEncode(['fixed128x128'], [-1]));
      var b =
          'ffffffffffffffffffffffffffffffff00000000000000000000000000000000';
      expect(a, b);
    });
  });

  group('encoding -1 as uint', () {
    test('should throw', () {
      expect(() => abi.rawEncode(['uint'], [-1]), throwsArgumentError);
    });
  });

  group('encoding 256 bits as bytes', () {
    test('should not leave trailing zeroes', () {
      var a = abi.rawEncode([
        'bytes'
      ], [
        hex.decode(
            'ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff')
      ]);
      expect(hex.encode(a),
          '00000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000020ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff');
    });
  });
}
