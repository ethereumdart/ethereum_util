import 'dart:convert';
import 'dart:io';

import 'package:convert/convert.dart';
import 'package:test/test.dart';

import 'package:ethereum_util/src/rlp.dart' as Rlp;
import 'package:path/path.dart' as path;


dynamic castTestValue(dynamic testValue) {
  if (testValue is String && testValue.startsWith('#')) {
    var bn = BigInt.parse(testValue.substring(1));
    return bn;
  }

  return testValue;
}

void main() {
  test('The string dog', () {
    var encoded = Rlp.encode('dog');
    expect(encoded.length, equals(4));
    expect(encoded, equals([0x83]..addAll('dog'.codeUnits)));
    expect(Rlp.decode(encoded), 'dog'.codeUnits);
  });

  test('The list cat, dog', () {
    var encoded = Rlp.encode(['cat', 'dog']);
    expect(encoded, equals([[0xc8, 0x83], 'cat'.codeUnits, [0x83], 'dog'.codeUnits].expand((x) => x).toList()));
    expect(Rlp.decode(encoded), ['cat'.codeUnits, 'dog'.codeUnits]);
  });

  test('The empty string', () {
    var encoded = Rlp.encode('');
    expect(encoded, equals([0x80]));
    expect(Rlp.decode(encoded), ''.codeUnits);
  });

  test('The empty list', () {
    var encoded = Rlp.encode([]);
    expect(encoded, equals([0xc0]));
    expect(Rlp.decode(encoded), []);
  });

  test('The integer 0', () {
    var encoded = Rlp.encode(0);
    expect(encoded, equals([0x80]));
    expect(Rlp.decode(encoded), []);
  });

  test('The integer 1', () {
    var encoded = Rlp.encode(1);
    expect(encoded, equals([0x01]));
    expect(Rlp.decode(encoded), [1]);
  });

  test('The encoded integer 0', () {
    var encoded = Rlp.encode('\x00');
    expect(encoded, equals([0x00]));
    expect(Rlp.decode(encoded), [0]);
  });

  test('The encoded integer 15', () {
    var encoded = Rlp.encode('\x0f');
    expect(encoded, equals([0x0f]));
    expect(Rlp.decode(encoded), [0x0f]);
  });

  test('The encoded integer 1024', () {
    var encoded = Rlp.encode('\x04\x00');
    expect(encoded, equals([0x82, 0x04, 0x00]));
    expect(Rlp.decode(encoded), [0x04, 0x00]);
  });

  test('The set theoretical representation of three', () {
    var encoded = Rlp.encode([
      [],
      [[]],
      [
        [],
        [[]]
      ]
    ]);
    expect(encoded, equals([0xc7, 0xc0, 0xc1, 0xc0, 0xc3, 0xc0, 0xc1, 0xc0]));
    expect(Rlp.decode(encoded), [
      [],
      [[]],
      [
        [],
        [[]]
      ]
    ]);
  });

  // Check behavior against the js version of rlp
  test('The string a', () {
    var encoded = Rlp.encode('a');
    expect(String.fromCharCodes(encoded), equals('a'));
    expect(Rlp.decode(encoded), 'a'.codeUnits);
  });

  test('length of string >55 should return 0xb7+len(len(data)) plus len(data) plus data', () {
    String input = 'zoo255zoo255zzzzzzzzzzzzssssssssssssssssssssssssssssssssssssssssssssss';
    var encoded = Rlp.encode(input);
    expect(encoded.length, equals(72));
    expect(encoded[0], equals(184));
    expect(encoded[1], equals(70));
    expect(encoded[2], equals(122));
    expect(encoded[3], equals(111));
    expect(encoded[12], equals(53));
    expect(Rlp.decode(encoded), input.codeUnits);
  });

  // Check behavior against the js version of rlp
  test('length of list 0-55 should return (0xc0+len(data)) plus data', () {
    var encoded = Rlp.encode(['dog', 'god', 'cat']);
    expect(encoded.length, equals(13));
    expect(encoded[0], equals(204));
    expect(encoded[1], equals(131));
    expect(encoded[11], equals(97));
    expect(encoded[12], equals(116));
    expect(Rlp.decode(encoded), ['dog'.codeUnits, 'god'.codeUnits, 'cat'.codeUnits]);
  });

  // Check behavior against the js version of rlp
  test('should not crash on an invalid rlp', () {
    Rlp.encode(String.fromCharCodes([
      239, 191, 189, 239, 191, 189, 239, 191, 189, 239, 191, 189, 239, 191, 189,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      239, 191, 189, 29, 239, 191, 189, 77, 239, 191, 189, 239, 191, 189, 239,
      191, 189, 93, 122, 239, 191, 189, 239, 191, 189, 239, 191, 189, 103, 239,
      191, 189, 239, 191, 189, 239, 191, 189, 26, 239, 191, 189, 18, 69, 27, 239,
      191, 189, 239, 191, 189, 116, 19, 239, 191, 189, 239, 191, 189, 66, 239,
      191, 189, 64, 212, 147, 71, 239, 191, 189,
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      239, 191, 189, 11, 222, 155, 122, 54, 42, 194, 169, 239, 191, 189, 70,
      239, 191, 189, 72, 239, 191, 189, 239, 191, 189, 54, 53, 239, 191, 189,
      100, 73, 239, 191, 189, 55, 239, 191, 189, 239, 191, 189, 59, 1, 239, 191,
      189, 109, 239, 191, 189, 239, 191, 189, 93, 239, 191, 189, 208, 128, 239,
      191, 189, 239, 191, 189, 0, 239, 191, 189, 239, 191, 189, 239, 191, 189,
      15, 66, 64, 239, 191, 189, 239, 191, 189, 239, 191, 189, 239, 191, 189, 4,
      239, 191, 189, 79, 103, 239, 191, 189, 85, 239, 191, 189, 239, 191, 189, 239,
      191, 189, 74, 239, 191, 189, 239, 191, 189, 239, 191, 189, 239, 191, 189, 54,
      239, 191, 189, 239, 191, 189, 239, 191, 189, 239, 191, 189, 239, 191, 189, 83,
      239, 191, 189, 14, 239, 191, 189, 239, 191, 189, 239, 191, 189, 4, 63, 239, 191,
      189, 63, 239, 191, 189, 41, 239, 191, 189, 239, 191, 189, 239, 191, 189, 67, 28,
      239, 191, 189, 239, 191, 189, 11, 239, 191, 189, 31, 239, 191, 189, 239, 191, 189,
      104, 96, 100, 239, 191, 189, 239, 191, 189, 12, 239, 191, 189, 239, 191, 189, 206,
      152, 239, 191, 189, 239, 191, 189, 31, 112, 111, 239, 191, 189, 239, 191, 189, 65,
      239, 191, 189, 41, 239, 191, 189, 239, 191, 189, 53, 84, 11, 239, 191, 189, 239, 191,
      189, 12, 102, 24, 12, 42, 105, 109, 239, 191, 189, 58, 239, 191, 189, 4, 239, 191,
      189, 104, 82, 9, 239, 191, 189, 6, 66, 91, 43, 38, 102, 117, 239, 191, 189, 105,
      239, 191, 189, 239, 191, 189, 239, 191, 189, 89, 127, 239, 191, 189, 114
    ]));
  });

  var jsonString = File(path.join(Directory.current.path, 'test/data/rlp.json')).readAsStringSync();
  Map tests = jsonDecode(jsonString);

  tests.entries.forEach((entry) {
    String key = entry.key;
    Map value = entry.value;
    dynamic testValue = value['in'];
    String expected = value['out'];

    test('Official test: $key', () {
      var encoded = Rlp.encode(castTestValue(testValue));
      var hexEncoded = hex.encode(encoded);
      expect(hexEncoded, expected);
    });
  });
}
