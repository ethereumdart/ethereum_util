import 'package:convert/convert.dart' show hex;
import 'package:test/test.dart';

import 'package:ethereum_util/src/utils/utils.dart' as util;

void main() {
  group('utils', () {
    test('should convert intToHex', () {
      expect(util.intToHex(0), '0x0');
    });

    test('should detect invalid length hex string', () {
      expect(util.isHexString('0x0', length: 2), false);
    });

    test('should stripHexPrefix strip prefix of valid strings', () {
      expect(util.stripHexPrefix('0xkdsfksfdkj'), 'kdsfksfdkj');
      expect(util.stripHexPrefix('0xksfdkj'), 'ksfdkj');
      expect(util.stripHexPrefix('0xkdsfdkj'), 'kdsfdkj');
      expect(util.stripHexPrefix('0x23442sfdkj'), '23442sfdkj');
      expect(util.stripHexPrefix('0xkdssdfssfdkj'), 'kdssdfssfdkj');
      expect(util.stripHexPrefix('0xaaaasfdkj'), 'aaaasfdkj');
      expect(
          util.stripHexPrefix('0xkdsdfsfsdfsdfsdfdkj'), 'kdsdfsfsdfsdfsdfdkj');
      expect(util.stripHexPrefix('0x111dssdddj'), '111dssdddj');
    });

    test('should stripHexPrefix strip prefix of mix hexed strings', () {
      expect(util.stripHexPrefix('0xkdsfksfdkj'), 'kdsfksfdkj');
      expect(util.stripHexPrefix('ksfdkj'), 'ksfdkj');
      expect(util.stripHexPrefix('kdsfdkj'), 'kdsfdkj');
      expect(util.stripHexPrefix('23442sfdkj'), '23442sfdkj');
      expect(util.stripHexPrefix('0xkdssdfssfdkj'), 'kdssdfssfdkj');
      expect(util.stripHexPrefix('aaaasfdkj'), 'aaaasfdkj');
      expect(util.stripHexPrefix('kdsdfsfsdfsdfsdfdkj'), 'kdsdfsfsdfsdfsdfdkj');
      expect(util.stripHexPrefix('111dssdddj'), '111dssdddj');
    });

    test('valid padToEven should pad to even', () {
      expect(util.padToEven('0').length % 2, 0);
      expect(util.padToEven('111').length % 2, 0);
      expect(util.padToEven('22222').length % 2, 0);
      expect(util.padToEven('ddd').length % 2, 0);
      expect(util.padToEven('aa').length % 2, 0);
      expect(util.padToEven('aaaaaa').length % 2, 0);
      expect(util.padToEven('sdssd').length % 2, 0);
      expect(util.padToEven('eee').length % 2, 0);
      expect(util.padToEven('w').length % 2, 0);
    });

    test('valid padToEven should pad to even check string prefix 0', () {
      expect(util.padToEven('0'), '00');
      expect(util.padToEven('111'), '0111');
      expect(util.padToEven('22222'), '022222');
      expect(util.padToEven('ddd'), '0ddd');
      expect(util.padToEven('aa'), 'aa');
      expect(util.padToEven('aaaaaa'), 'aaaaaa');
      expect(util.padToEven('sdssd'), '0sdssd');
      expect(util.padToEven('eee'), '0eee');
      expect(util.padToEven('w'), '0w');
    });

    test('valid isHexString tests', () {
      expect(util.isHexString('0x0e026d45820d91356fc73d7ff2bdef353ebfe7e9'), true);
      expect(util.isHexString('0x1e026d45820d91356fc73d7ff2bdef353ebfe7e9'), true);
      expect(util.isHexString('0x6e026d45820d91356fc73d7ff2bdef353ebfe7e9'), true);
      expect(util.isHexString('0xecfaa1a0c4372a2ac5cca1e164510ec8df04f681fc960797f1419802ec00b225'), true);
      expect(util.isHexString('0x6e0e6d45820d91356fc73d7ff2bdef353ebfe7e9'), true);
      expect(util.isHexString('0x620e6d45820d91356fc73d7ff2bdef353ebfe7e9'), true);
      expect(util.isHexString('0x1e0e6d45820d91356fc73d7ff2bdef353ebfe7e9'), true);
      expect(util.isHexString('0x2e0e6d45820d91356fc73d7ff2bdef353ebfe7e9'), true);
      expect(util.isHexString('0x220c96d48733a847570c2f0b40daa8793b3ae875b26a4ead1f0f9cead05c3863'), true);
      expect(util.isHexString('0x2bb303f0ae65c64ef80a3bb3ee8ceef5d50065bd'), true);
      expect(util.isHexString('0x6e026d45820d91256fc73d7ff2bdef353ebfe7e9'), true);
    });

    test('invalid isHexString tests', () {
      expect(util.isHexString(' 0x0e026d45820d91356fc73d7ff2bdef353ebfe7e9'), false);
      expect(util.isHexString('fdsjfsd'), false);
      expect(util.isHexString(' 0xfdsjfsd'), false);
      expect(util.isHexString('0xfds*jfsd'), false);
      expect(util.isHexString('0xfds\$jfsd'), false);
      expect(util.isHexString('0xf@dsjfsd'), false);
      expect(util.isHexString('0xfdsjf!sd'), false);
      expect(util.isHexString('fds@@jfsd'), false);
    });

    test('valid arrayContainsArray should array contain every array', () {
      expect(util.arrayContainsArray([1, 2, 3], [1, 2]), true);
      expect(util.arrayContainsArray([3, 3], [3, 3]), true);
      expect(util.arrayContainsArray([1, 2, 'h'], [1, 2, 'h']), true);
      expect(util.arrayContainsArray([1, 2, 'fsffds'], [1, 2, 'fsffds']), true);
      expect(util.arrayContainsArray([1], [1]), true);
      expect(util.arrayContainsArray([], []), true);
      expect(util.arrayContainsArray([1, 3333], [1, 3333]), true);
    });

    test('valid getBinarySize should get binary size of string', () {
      expect(util.getBinarySize('0x0e026d45820d91356fc73d7ff2bdef353ebfe7e9'), 42);
      expect(util.getBinarySize('0x220c96d48733a847570c2f0b40daa8793b3ae875b26a4ead1f0f9cead05c3863'), 66);
    });

    test('valid arrayContainsArray should array some every array', () {
      expect(util.arrayContainsArray([1, 2], [1], some: true), true);
      expect(util.arrayContainsArray([3, 3], [3, 2323], some: true), true);
      expect(util.arrayContainsArray([1, 2, 'h'], [2332, 2, 'h'], some: true), true);
      expect(util.arrayContainsArray([1, 2, 'fsffds'], [3232, 2, 'fsffds'], some: true), true);
      expect(util.arrayContainsArray([1], [1], some: true), true);
      expect(util.arrayContainsArray([1, 3333], [1, 323232], some: true), true);
    });

    test('fromAscii', () {
      expect(util.fromAscii('myString'), '0x6d79537472696e67');
      expect(util.fromAscii('myString\x00'), '0x6d79537472696e6700');
      expect(
        util.fromAscii(  '\u0003\u0000\u0000\u00005èÆÕL]\u0012|Î¾\u001a7«\u00052\u0011(ÐY\n<\u0010\u0000\u0000\u0000\u0000\u0000\u0000e!ßd/ñõì\f:z¦Î¦±ç·÷Í¢Ëß\u00076*\bñùC1ÉUÀé2\u001aÓB'),
        '0x0300000035e8c6d54c5d127c9dcebe9e1a37ab9b05321128d097590a3c100000000000006521df642ff1f5ec0c3a7aa6cea6b1e7b7f7cda2cbdf07362a85088e97f19ef94331c955c0e9321ad386428c'
      );
    });

    test('fromUtf8', () {
      expect(util.fromUtf8('myString'), '0x6d79537472696e67');
      expect(util.fromUtf8('myString\x00'), '0x6d79537472696e67');
      expect(util.fromUtf8('expected value\u0000\u0000\u0000'), '0x65787065637465642076616c7565');
    });

    test('toUtf8', () {
      expect(util.toUtf8('0x6d79537472696e67'), 'myString');
      expect(util.toUtf8('0x6d79537472696e6700'), 'myString');
      expect(util.toUtf8('0x65787065637465642076616c7565000000000000000000000000000000000000'), 'expected value');
    });

    test('toAsciiTests', () {
      expect(util.toAscii('0x6d79537472696e67'), 'myString');
      expect(util.toAscii('0x6d79537472696e6700'), 'myString\u0000');
      expect(
        util.toAscii('0x0300000035e8c6d54c5d127c9dcebe9e1a37ab9b05321128d097590a3c100000000000006521df642ff1f5ec0c3a7aa6cea6b1e7b7f7cda2cbdf07362a85088e97f19ef94331c955c0e9321ad386428c'),
        '\u0003\u0000\u0000\u00005èÆÕL]\u0012|Î¾\u001a7«\u00052\u0011(ÐY\n<\u0010\u0000\u0000\u0000\u0000\u0000\u0000e!ßd/ñõì\f:z¦Î¦±ç·÷Í¢Ëß\u00076*\bñùC1ÉUÀé2\u001aÓB'
      );
    });

    group('intToHex', () {
      test('should convert a int to hex', () {
        const i = 6003400;
        expect(util.intToHex(i), '0x5b9ac8');
      });
    });

    group('intToBuffer', () {
      test('should convert a int to a buffer', () {
        const i = 6003400;
        var buf = util.intToBuffer(i);
        expect(hex.encode(buf), '5b9ac8');
      });

      test('should convert a int to a buffer for odd length hex values', () {
        const i = 1;
        var buf = util.intToBuffer(i);
        expect(hex.encode(buf), '01');
      });
    });
  });
}
