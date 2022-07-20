import 'package:convert/convert.dart' show hex;
import 'package:test/test.dart';

import 'package:ethereum_util/src/hash.dart' as hash;

void main() {
  const msg = '0x3c9229289a6125f7fdf1885a77bb12c37a8d3b4962d936f7e3084dece32a3ca1';

  group('keccak', () {
    test('should produce a hash', () {
      const r = '82ff40c0a986c6a5cfad4ddf4c3aa6996f1a7837f9c398e17e5de5cbd5a12b28';
      var hashBuffer = hash.keccak(msg);
      expect(hex.encode(hashBuffer), r);
    });
  });

  group('keccak256', () {
    test('should produce a hash (keccak(a, 256) alias)', () {
      const r = '82ff40c0a986c6a5cfad4ddf4c3aa6996f1a7837f9c398e17e5de5cbd5a12b28';
      var hashBuffer = hash.keccak256(msg);
      expect(hex.encode(hashBuffer), r);
    });
  });

  group('keccak without hex prefix', () {
    test('should produce a hash', () {
      const message = '3c9229289a6125f7fdf1885a77bb12c37a8d3b4962d936f7e3084dece32a3ca1';
      const r = '22ae1937ff93ec72c4d46ff3e854661e3363440acd6f6e4adf8f1a8978382251';
      var hashBuffer = hash.keccak(message);
      expect(hex.encode(hashBuffer), r);
    });
  });

  group('keccak-512', () {
    test('should produce a hash', () {
      const r = '36fdacd0339307068e9ed191773a6f11f6f9f99016bd50f87fd529ab7c87e1385f2b7ef1ac257cc78a12dcb3e5804254c6a7b404a6484966b831eadc721c3d24';
      var hashBuffer = hash.keccak(msg, bits: 512);
      expect(hex.encode(hashBuffer), r);
    });
  });

  group('sha256', () {
    test('should produce a sha256', () {
      const r = '58bbda5e10bc11a32d808e40f9da2161a64f00b5557762a161626afe19137445';
      var hashBuffer = hash.sha256(msg);
      expect(hex.encode(hashBuffer), r);
    });
  });

  group('ripemd160', () {
    test('should produce a ripemd160', () {
      const r = '4bb0246cbfdfddbe605a374f1187204c896fabfd';
      var hashBuffer = hash.ripemd160(msg);
      expect(hex.encode(hashBuffer), r);
    });

    test('should produce a padded ripemd160', () {
      const r = '0000000000000000000000004bb0246cbfdfddbe605a374f1187204c896fabfd';
      var hashBuffer = hash.ripemd160(msg, padded: true);
      expect(hex.encode(hashBuffer), r);
    });
  });

  group('rlphash', () {
    test('should produce a keccak-256 hash of the rlp data', () {
      const r = '33f491f24abdbdbf175e812b94e7ede338d1c7f01efb68574acd279a15a39cbe';
      var hashBuffer = hash.rlphash(msg);
      expect(hex.encode(hashBuffer), r);
    });
  });
}
