import 'dart:typed_data';

import 'package:convert/convert.dart' show hex;
import 'package:test/test.dart';

import 'package:ethereum_util/src/utils/bytes.dart';

void main() {
  group('bytes', () {
    group('zeros', () {
      test('should produce lots of 0s', () {
        var z60 = zeros(30);
        const zs60 =
            '000000000000000000000000000000000000000000000000000000000000';
        expect(hex.encode(z60), zs60);
      });
    });

    group('pad', () {
      test('should left pad a Buffer', () {
        var buf = Uint8List.fromList([9, 9]);
        var padded = setLength(buf, 3);
        expect(hex.encode(padded), '000909');
      });
      test('should left truncate a Buffer', () {
        var buf = Uint8List.fromList([9, 0, 9]);
        var padded = setLength(buf, 2);
        expect(hex.encode(padded), '0009');
      });
      test('should left pad a Buffer - alias', () {
        var buf = Uint8List.fromList([9, 9]);
        var padded = setLengthLeft(buf, 3);
        expect(hex.encode(padded), '000909');
      });
    });

    group('rpad', () {
      test('should right pad a Buffer', () {
        var buf = Uint8List.fromList([9, 9]);
        var padded = setLength(buf, 3, right: true);
        expect(hex.encode(padded), '090900');
      });
      test('should right truncate a Buffer', () {
        var buf = Uint8List.fromList([9, 0, 9]);
        var padded = setLength(buf, 2, right: true);
        expect(hex.encode(padded), '0900');
      });
      test('should right pad a Buffer - alias', () {
        var buf = Uint8List.fromList([9, 9]);
        var padded = setLengthRight(buf, 3);
        expect(hex.encode(padded), '090900');
      });
    });

    group('unpadString', () {
      test('should unpad a hex string', () {
        const str = '00000000006600';
        var r = unpadString(str);
        expect(r, '6600');
      });

      test('should unpad a hex string with prefix', () {
        const str = '0x0000000006600';
        var r = unpadString(str);
        expect(r, '6600');
      });
    });

    group('toBuffer', () {
      test('should work', () {
        // Buffer
        expect(toBuffer(Uint8List(0)), Uint8List(0));
        // Array
        expect(toBuffer(Uint8List(0)), Uint8List(0));
        // String
        expect(toBuffer('11'), Uint8List.fromList([49, 49]));
        expect(toBuffer('0x11'), Uint8List.fromList([17]));
        expect(hex.encode(toBuffer('1234')), '31323334');
        expect(hex.encode(toBuffer('0x1234')), '1234');
        // Number
        expect(toBuffer(1), Uint8List.fromList([1]));
        // null
        expect(toBuffer(null), Uint8List(0));
        // 'toBN'
        expect(toBuffer(BigInt.from(1)), Uint8List.fromList([1]));
      });
      test('should fail', () {
        expect(() => toBuffer({test: 1}), throwsA('invalid type'));
      });
    });

    group('bufferToInt', () {
      test('should convert a int to hex', () {
        var buf = Uint8List.fromList(hex.decode('5b9ac8'));
        var i = bufferToInt(buf);
        expect(i, 6003400);
      });
      test('should convert empty input to 0', () {
        expect(bufferToInt(Uint8List(0)), 0);
      });
    });

    group('bufferToHex', () {
      test('should convert a buffer to hex', () {
        expect(bufferToHex(Uint8List.fromList(hex.decode('5b9ac8'))), '0x5b9ac8');
      });
      test('empty buffer', () {
        expect(bufferToHex(Uint8List(0)), '0x');
      });
    });

    group('fromSigned', () {
      test('should convert an unsigned (negative) buffer to a singed number', () {
        const neg = '-452312848583266388373324160190187140051835877600158453279131187530910662656';
        var buf = Uint8List(32);
        buf.fillRange(0, 32, 0);
        buf[0] = 255;

        expect(fromSigned(buf).toString(), neg);
      });
      test('should convert an unsigned (postestive) buffer to a singed number', () {
        const neg = '452312848583266388373324160190187140051835877600158453279131187530910662656';
        var buf = Uint8List(32);
        buf.fillRange(0, 32, 0);
        buf[0] = 1;

        expect(fromSigned(buf).toString(), neg);
      });
    });

    group('toUnsigned', () {
      test('should convert a signed (negative) number to unsigned', () {
        const neg = '-452312848583266388373324160190187140051835877600158453279131187530910662656';
        const encoded = 'ff00000000000000000000000000000000000000000000000000000000000000';
        var num = BigInt.parse(neg, radix: 10);

        expect(hex.encode(toUnsigned(num)), encoded);
      });

      test('should convert a signed (postestive) number to unsigned', () {
        const neg = '452312848583266388373324160190187140051835877600158453279131187530910662656';
        const encoded = '0100000000000000000000000000000000000000000000000000000000000000';
        var num = BigInt.parse(neg, radix: 10);

        expect(hex.encode(toUnsigned(num)), encoded);
      });
    });

    group('addHexPrefix', () {
      const string = 'd658a4b8247c14868f3c512fa5cbb6e458e4a989';
      test('should add', () {
        expect(addHexPrefix(string), '0xd658a4b8247c14868f3c512fa5cbb6e458e4a989');
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
        expect(baToJSON(ba), '["0x00","0x01",["0x02"]]');
      });
      test('should turn a buffers into string', () {
        expect(baToJSON(Uint8List.fromList([0])), '"0x00"');
      });
    });
  });
}
