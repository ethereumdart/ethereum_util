import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:convert/convert.dart';
import 'package:ethereum_util/src/bytes.dart';
import 'package:ethereum_util/src/rlp.dart' as Rlp;
import 'package:path/path.dart' as path;
import "package:pointycastle/pointycastle.dart";
import 'package:test/test.dart';

dynamic castTestValue(dynamic testValue) {
  if (testValue is String && testValue.startsWith('#')) {
    var bn = BigInt.parse(testValue.substring(1));
    return bn;
  } else {
    return testValue;
  }
}

void main() {
  test('The string dog', () {
    var encoded = Rlp.encode('dog');
    expect(encoded.length, equals(4));
    expect(encoded, equals([0x83]..addAll('dog'.codeUnits)));
  });

  test('The list cat, dog', () {
    var encoded = Rlp.encode(['cat', 'dog']);
    expect(
        encoded,
        equals([
          [0xc8, 0x83],
          'cat'.codeUnits,
          [0x83],
          'dog'.codeUnits
        ].expand((x) => x).toList()));
  });

  test('The empty string', () {
    var encoded = Rlp.encode('');
    expect(encoded, equals([0x80]));
  });

  test('The empty list', () {
    var encoded = Rlp.encode([]);
    expect(encoded, equals([0xc0]));
  });

  test('The integer 0', () {
    var encoded = Rlp.encode(0);
    expect(encoded, equals([0x80]));
  });

  test('The integer 1', () {
    var encoded = Rlp.encode(1);
    expect(encoded, equals([0x01]));
  });

  test('The encoded integer 0', () {
    var encoded = Rlp.encode('\x00');
    expect(encoded, equals([0x00]));
  });

  test('The encoded integer 15', () {
    var encoded = Rlp.encode('\x0f');
    expect(encoded, equals([0x0f]));
  });

  test('The encoded integer 1024', () {
    var encoded = Rlp.encode('\x04\x00');
    expect(encoded, equals([0x82, 0x04, 0x00]));
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
  });

  // Check behaviour against the js version of rlp
  test('The string a', () {
    var encoded = Rlp.encode('a');
    expect(String.fromCharCodes(encoded), equals('a'));
  });

  test(
      'length of string >55 should return 0xb7+len(len(data)) plus len(data) plus data',
      () {
    var encoded = Rlp.encode(
        'zoo255zoo255zzzzzzzzzzzzssssssssssssssssssssssssssssssssssssssssssssss');
    expect(encoded.length, equals(72));
    expect(encoded[0], equals(184));
    expect(encoded[1], equals(70));
    expect(encoded[2], equals(122));
    expect(encoded[3], equals(111));
    expect(encoded[12], equals(53));
  });

  // Check behaviour against the js version of rlp
  test('length of list 0-55 should return (0xc0+len(data)) plus data', () {
    var encoded = Rlp.encode(['dog', 'god', 'cat']);
    expect(encoded.length, equals(13));
    expect(encoded[0], equals(204));
    expect(encoded[1], equals(131));
    expect(encoded[11], equals(97));
    expect(encoded[12], equals(116));
  });

  // Check behaviour against the js version of rlp
  test('should not crash on an invalid rlp', () {
    Rlp.encode(String.fromCharCodes([
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      239,
      191,
      189,
      29,
      239,
      191,
      189,
      77,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      93,
      122,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      103,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      26,
      239,
      191,
      189,
      18,
      69,
      27,
      239,
      191,
      189,
      239,
      191,
      189,
      116,
      19,
      239,
      191,
      189,
      239,
      191,
      189,
      66,
      239,
      191,
      189,
      64,
      212,
      147,
      71,
      239,
      191,
      189,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      0,
      239,
      191,
      189,
      11,
      222,
      155,
      122,
      54,
      42,
      194,
      169,
      239,
      191,
      189,
      70,
      239,
      191,
      189,
      72,
      239,
      191,
      189,
      239,
      191,
      189,
      54,
      53,
      239,
      191,
      189,
      100,
      73,
      239,
      191,
      189,
      55,
      239,
      191,
      189,
      239,
      191,
      189,
      59,
      1,
      239,
      191,
      189,
      109,
      239,
      191,
      189,
      239,
      191,
      189,
      93,
      239,
      191,
      189,
      208,
      128,
      239,
      191,
      189,
      239,
      191,
      189,
      0,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      15,
      66,
      64,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      4,
      239,
      191,
      189,
      79,
      103,
      239,
      191,
      189,
      85,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      74,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      54,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      83,
      239,
      191,
      189,
      14,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      4,
      63,
      239,
      191,
      189,
      63,
      239,
      191,
      189,
      41,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      67,
      28,
      239,
      191,
      189,
      239,
      191,
      189,
      11,
      239,
      191,
      189,
      31,
      239,
      191,
      189,
      239,
      191,
      189,
      104,
      96,
      100,
      239,
      191,
      189,
      239,
      191,
      189,
      12,
      239,
      191,
      189,
      239,
      191,
      189,
      206,
      152,
      239,
      191,
      189,
      239,
      191,
      189,
      31,
      112,
      111,
      239,
      191,
      189,
      239,
      191,
      189,
      65,
      239,
      191,
      189,
      41,
      239,
      191,
      189,
      239,
      191,
      189,
      53,
      84,
      11,
      239,
      191,
      189,
      239,
      191,
      189,
      12,
      102,
      24,
      12,
      42,
      105,
      109,
      239,
      191,
      189,
      58,
      239,
      191,
      189,
      4,
      239,
      191,
      189,
      104,
      82,
      9,
      239,
      191,
      189,
      6,
      66,
      91,
      43,
      38,
      102,
      117,
      239,
      191,
      189,
      105,
      239,
      191,
      189,
      239,
      191,
      189,
      239,
      191,
      189,
      89,
      127,
      239,
      191,
      189,
      114
    ]));
  });

  var jsonString = File(path.join(Directory.current.path, 'test/data/rlp.json'))
      .readAsStringSync();
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

  test('Random contract address from nonce and sender', () {
    var encoded =
        Rlp.encode([toBuffer('0xdb6a20a121dbdfac68b172456f90e594fe206e01'), 3]);
    var out = Digest('SHA-3/256').process(Uint8List.fromList(encoded));
    expect(hex.encode(out.sublist(12)),
        equals('52d1b00ecb88d6aebc15d21559b368e818df388c'));
  });

  test('Cryptokitties contract address from nonce and sender', () {
    var encoded = Rlp.encode(
        [toBuffer('0xba52c75764d6f594735dc735be7f1830cdf58ddf'), 3515]);
    var out = Digest('SHA-3/256').process(Uint8List.fromList(encoded));
    print(hex.encode(out.sublist(12)));
    expect(hex.encode(out.sublist(12)),
        equals('06012c8cf97bead5deae237070f9587f8e7a266d'));
  });
}
