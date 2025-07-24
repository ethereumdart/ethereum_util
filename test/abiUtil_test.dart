import 'package:test/test.dart';
import 'dart:typed_data';

import 'package:ethereum_util/src/utils/abi.dart';

void main() {
  group('AbiUtil supplementary test', () {
    test('rawEncode', () {
      List<String> types = ['int[]'];
      List values = [
        [1234]
      ];
      final result = AbiUtil.rawEncode(types, values);
      expect(result.length, 96);
    });
  });

  group('AbiUtil supplementary test encodeSingle', () {
    test('bool', () {
      String type = 'bool';
      dynamic arg = true;
      final result = AbiUtil.encodeSingle(type, arg);
      expect(result.length, 32);
      arg = 1;
      final resultInt = AbiUtil.encodeSingle(type, arg);
      arg = '1';
      final resultString = AbiUtil.encodeSingle(type, arg);
      expect(resultInt, resultString);
    });

    test('ufixed', () {
      String type = 'ufixed';
      dynamic arg = 1;
      final result = AbiUtil.encodeSingle(type, arg);
      expect(result.length, 32);
    });

    test('fixed', () {
      String type = 'fixed';
      dynamic arg = 1;
      final result = AbiUtil.encodeSingle(type, arg);
      expect(result.length, 32);
    });

    test('bytes', () {
      String type = 'bytes';
      Uint8List arg = new Uint8List(33);
      final result = AbiUtil.encodeSingle(type, arg);
      expect(result.length, 96);
    });
  });

  group('AbiUtil supplementary test solidity', () {
    test('string', () {
      List<String> types = ['string'];
      List values = ['test'];
      final result = AbiUtil.soliditySHA3(types, values);
      expect(result.length, 32);
    });

    test('bytes', () {
      List<String> types = ['bytes'];
      List values = [new Uint8List(32)];
      final result = AbiUtil.soliditySHA3(types, values);
      expect(result.length, 32);
    });

    test('address', () {
      List<String> types = ['address'];
      List values = [new Uint8List(32)];
      final result = AbiUtil.soliditySHA3(types, values);
      expect(result.length, 32);
    });

    test('uint and int', () {
      List<String> types = ['uint', 'int'];
      List values = [1, 2];
      final result = AbiUtil.soliditySHA3(types, values);
      expect(result.length, 32);
    });

    /// error in soliditySHA3 array type
    test('array', () {
      List<String> types = ['bytes[]'];
      List values = [
        [new Uint8List(32)]
      ];
      try {
        final result = AbiUtil.soliditySHA3(types, values);
        expect(result.length, 32);
      } catch (error) {}
    });
  });
  group('AbiUtil supplementary test error', () {
    test('encodeSingle unsupported type', () {
      String type = 'errorType';
      dynamic arg = 1;
      try {
        AbiUtil.encodeSingle(type, arg);
      } catch (error) {
        expect(error.toString(),
            'Invalid argument(s): Unsupported or invalid type: errorType');
      }
    });

    test('encodeSingle invalid int', () {
      String type = 'int';
      dynamic arg = 'abc';
      try {
        AbiUtil.encodeSingle(type, arg);
      } catch (error) {
        expect(
            error.toString(), 'Invalid argument(s): Invalid int<N> width: 1');
      }
    });

    test('rawEncode invalid argument', () {
      List<String> types = ['int[]'];
      List values = [1];
      try {
        AbiUtil.rawEncode(types, values);
      } catch (error) {
        expect(error.toString(), 'Invalid argument(s): Not an array?');
      }
    });

    test('solidity arg number not matching', () {
      List<String> types = ['int'];
      List values = [1, 2];
      try {
        AbiUtil.soliditySHA3(types, values);
      } catch (error) {
        expect(error.toString(),
            'Invalid argument(s): Number of types are not matching the values');
      }
    });

    test('solidity unsupported type', () {
      List<String> types = ['error'];
      List values = ['test'];
      try {
        AbiUtil.soliditySHA3(types, values);
      } catch (error) {
        expect(error.toString(),
            'Invalid argument(s): Unsupported or invalid type: error');
      }
    });
  });
}
