import 'dart:typed_data';

import 'package:convert/convert.dart' show hex;
import 'package:ethereum_util/src/bytes.dart' as bytes;
import 'package:test/test.dart';

void main() {
  group('bytes', () {
    group('zeros', () {
      test('should produce lots of 0s', () {
        var z60 = bytes.zeros(30);
        const zs60 = '000000000000000000000000000000000000000000000000000000000000';
        expect(hex.encode(z60), zs60);
      });
    });

    group('pad', () {
      test('should left pad a Buffer', () {
        var buf = Uint8List.fromList([9, 9]);
        var padded = bytes.setLength(buf, 3);
        expect(hex.encode(padded), '000909');
      });
      test('should left truncate a Buffer', () {
        var buf = Uint8List.fromList([9, 0, 9]);
        var padded = bytes.setLength(buf, 2);
        expect(hex.encode(padded), '0009');
      });
      test('should left pad a Buffer - alias', () {
        var buf = Uint8List.fromList([9, 9]);
        var padded = bytes.setLengthLeft(buf, 3);
        expect(hex.encode(padded), '000909');
      });
    });

    group('rpad', () {
      test('should right pad a Buffer', () {
        var buf = Uint8List.fromList([9, 9]);
        var padded = bytes.setLength(buf, 3, right: true);
        expect(hex.encode(padded), '090900');
      });
      test('should right truncate a Buffer', () {
        var buf = Uint8List.fromList([9, 0, 9]);
        var padded = bytes.setLength(buf, 2, right: true);
        expect(hex.encode(padded), '0900');
      });
      test('should right pad a Buffer - alias', () {
        var buf = Uint8List.fromList([9, 9]);
        var padded = bytes.setLengthRight(buf, 3);
        expect(hex.encode(padded), '090900');
      });
    });

    group('unpadString', () {
      test('should unpad a hex string', () {
        const str = '00000000006600';
        var r = bytes.unpadString(str);
        expect(r, '6600');
      });

      test('should unpad a hex string with prefix', () {
        const str = '0x0000000006600';
        var r = bytes.unpadString(str);
        expect(r, '6600');
      });
    });

    group('toBuffer', () {
      test('should work', () {
        // Buffer
        expect(bytes.toBuffer(Uint8List(0)), Uint8List(0));
        // Array
        expect(bytes.toBuffer(Uint8List(0)), Uint8List(0));
        // String
        expect(bytes.toBuffer('11'), Uint8List.fromList([49, 49]));
        expect(bytes.toBuffer('0x11'), Uint8List.fromList([17]));
        expect(hex.encode(bytes.toBuffer('1234')), '31323334');
        expect(hex.encode(bytes.toBuffer('0x1234')), '1234');
        // Number
        expect(bytes.toBuffer(1), Uint8List.fromList([1]));
        // null
        expect(bytes.toBuffer(null), Uint8List(0));
        // 'toBN'
        expect(bytes.toBuffer(BigInt.from(1)), Uint8List.fromList([1]));
      });
      test('should fail', () {
        expect(() => bytes.toBuffer({test: 1}), throwsA('invalid type'));
      });
    });

    group('bufferToInt', () {
      test('should convert a int to hex', () {
        var buf = hex.decode('5b9ac8');
        var i = bytes.bufferToInt(buf);
        expect(i, 6003400);
      });
      test('should convert empty input to 0', () {
        expect(bytes.bufferToInt(Uint8List(0)), 0);
      });
    });

    group('bufferToHex', () {
      test('should convert a buffer to hex', () {
        expect(bytes.bufferToHex(hex.decode('5b9ac8')), '0x5b9ac8');
      });
      test('empty buffer', () {
        expect(bytes.bufferToHex(Uint8List(0)), '0x');
      });
    });

    group('hex prefix', () {
      const string = 'd658a4b8247c14868f3c512fa5cbb6e458e4a989';
      test('should add', () {
        expect(bytes.addHexPrefix(string), '0xd658a4b8247c14868f3c512fa5cbb6e458e4a989');
      });
    });

    group('baToJSON', () {
      test('should turn a array of buffers into a pure json object', () {
        var ba = [
          Uint8List.fromList([0]),
          Uint8List.fromList([1]),
          [
            Uint8List.fromList([2])
          ]
        ];
        expect(bytes.baToJSON(ba), '["0x00","0x01",["0x02"]]');
      });
      test('should turn a buffers into string', () {
        expect(bytes.baToJSON(Uint8List.fromList([0])), '"0x00"');
      });
    });
  });
}
