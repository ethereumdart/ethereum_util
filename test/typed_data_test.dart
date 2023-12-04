import 'dart:typed_data';
import 'dart:convert';

import 'package:convert/convert.dart';
import 'package:ethereum_util/ethereum_util.dart';
import 'package:test/test.dart';

import 'package:ethereum_util/src/typed_data/models.dart';
import 'package:ethereum_util/src/typed_data/util.dart';
import 'package:ethereum_util/src/typed_data/signature.dart';

void main() {
  const privateKey =
      '4af1bceebf7f3634ec3cff8a2c38e51178d5d4ce585c52d6043e5e2cc3418bb0';
  const json =
      r'''{"types":{"EIP712Domain":[{"type":"string","name":"name"},{"type":"string","name":"version"},{"type":"uint256","name":"chainId"},{"type":"address","name":"verifyingContract"}],"Part":[{"name":"account","type":"address"},{"name":"value","type":"uint96"}],"Mint721":[{"name":"tokenId","type":"uint256"},{"name":"tokenURI","type":"string"},{"name":"creators","type":"Part[]"},{"name":"royalties","type":"Part[]"}]},"domain":{"name":"Mint721","version":"1","chainId":4,"verifyingContract":"0x2547760120aed692eb19d22a5d9ccfe0f7872fce"},"primaryType":"Mint721","message":{"@type":"ERC721","contract":"0x2547760120aed692eb19d22a5d9ccfe0f7872fce","tokenId":"1","uri":"ipfs://ipfs/hash","creators":[{"account":"0xc5eac3488524d577a1495492599e8013b1f91efa","value":10000}],"royalties":[],"tokenURI":"ipfs://ipfs/hash"}}''';
  test('should sign data with custom type which has an array', () {
    final signature = signTypedData(
        privateKey: Uint8List.fromList(hex.decode(privateKey)),
        jsonData: json,
        version: TypedDataVersion.V4);
    expect(signature,
        '0x2ce14898e255b8d1e5f296a293548607720951e507a5416a0515baef0420984f2e28df8824206db9dbab0e7f5b14eeb834d48ada4444e5f15e7bfd777d2069481c');
  });

  group('typed data util', () {
    test('hash message V1', () {
      final version = TypedDataVersion.V1;
      const json = r'''{"type":"string","name":"name","value":"value"}''';
      final result =
          TypedDataUtil.hashMessage(jsonData: json, version: version);
      expect(result.length, 32);
      const jsonList =
          r'''[{"type":"string","name":"name","value":"value"},{"type":"string","name":"name","value":"value"}]''';
      final resultList =
          TypedDataUtil.hashMessage(jsonData: jsonList, version: version);
      expect(resultList.length, 32);
    });

    test('recoverPublicKey V1', () {
      final version = TypedDataVersion.V1;
      final data = [
        new EIP712TypedData(name: "name", type: "bytes", value: 'test')
      ];
      final sig =
          '0x99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca661b';

      final result = TypedDataUtil.recoverPublicKey(data, sig, version);
      expect(result!.length, 64);
    });

    test('recoverPublicKey V4', () {
      final version = TypedDataVersion.V4;
      const json =
          r'''{"types":{"EIP712Domain":[{"type":"string","name":"name"},{"type":"string","name":"version"},{"type":"uint256","name":"chainId"},{"type":"address","name":"verifyingContract"}],"Part":[{"name":"account","type":"address"},{"name":"value","type":"uint96"}],"Mint721":[{"name":"tokenId","type":"uint256"},{"name":"tokenURI","type":"string"},{"name":"creators","type":"Part[]"},{"name":"royalties","type":"Part[]"}]},"domain":{"name":"Mint721","version":"1","chainId":4,"verifyingContract":"0x2547760120aed692eb19d22a5d9ccfe0f7872fce"},"primaryType":"Mint721","message":{"@type":"ERC721","contract":"0x2547760120aed692eb19d22a5d9ccfe0f7872fce","tokenId":"1","uri":"ipfs://ipfs/hash","creators":[{"account":"0xc5eac3488524d577a1495492599e8013b1f91efa","value":10000}],"royalties":[],"tokenURI":"ipfs://ipfs/hash"}}''';
      final rawTypedData = jsonDecode(json);
      final sig =
          '0x99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca661b';
      final result = TypedDataUtil.recoverPublicKey(
          TypedMessage.fromJson(rawTypedData), sig, version);
      expect(result!.length, 64);
    });

    test('recoverPublicKey V3', () {
      final version = TypedDataVersion.V3;
      Map<String, List<TypedDataField>> types = {
        "EIP712Domain": [
          TypedDataField(name: "EIP712Domain", type: "EIP712Domain")
        ]
      };
      final primaryType = 'EIP712Domain';
      EIP712Domain? domain = EIP712Domain(
          name: 'name',
          version: 'version',
          chainId: 1,
          salt: 'salt',
          verifyingContract: 'verifyingContract');
      domain.toJson();
      Map<String, dynamic> message = {"EIP712Domain": "EIP712Domain"};
      final data = TypedMessage(
          types: types,
          primaryType: primaryType,
          domain: domain,
          message: message);
      data.toJson();
      final sig =
          '0x99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca661b';
      try {
        final result = TypedDataUtil.recoverPublicKey(data, sig, version);
        print(result);
      } catch (error) {
        // print(error);
      }
    });
  });

  group('typed data signature', () {
    var privateKey =
        encodeBigInt(new BigInt.from(9223372036854775807), length: 32);
    var message = new Uint8List(32);
    var ECDSASig;
    final sig =
        '0x99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca661b';
    test('signPersonalMessage', () {
      final result = SignatureUtil.signPersonalMessage(
          message: message, privateKey: privateKey);
      expect(result.length, 132);
    });

    test('signToCompact', () {
      final result =
          SignatureUtil.signToCompact(message: message, privateKey: privateKey);
      assert(result.startsWith('0x'));
    });

    test('fromRpcSig', () {
      ECDSASig = SignatureUtil.fromRpcSig(sig);
      expect(ECDSASig.runtimeType, ECDSASignature);
    });

    test('recoverPublicKeyFromSignature', () {
      final result =
          SignatureUtil.recoverPublicKeyFromSignature(ECDSASig, message);
      expect(result!.length, 64);
    });

    test('ecRecover', () {
      final result = SignatureUtil.ecRecover(
          signature: sig, message: message, isPersonalSign: true);
      assert(result.startsWith('0x'));
    });
  });

  group('typed data', () {
    test('concatSig', () {
      final sig =
          '0x99e71a99cb2270b8cac5254f9e99b6210c6c10224a1579cf389ef88b20a1abe9129ff05af364204442bdb53ab6f18a99ab48acc9326fa689f228040429e3ca661b';
      final ECDSASig = SignatureUtil.fromRpcSig(sig);
      Uint8List r = encodeBigInt(ECDSASig.r);
      Uint8List s = encodeBigInt(ECDSASig.s);
      Uint8List v = encodeBigInt(new BigInt.from(ECDSASig.v));
      final result = concatSig(r, s, v);
      expect(result.length, 132);
    });

    test('signTypedDataCompact', () {
      const json = r'''{"type":"string","name":"name","value":"value"}''';
      var privateKey =
          encodeBigInt(new BigInt.from(9223372036854775807), length: 32);
      final version = TypedDataVersion.V1;
      final result = signTypedDataCompact(
          privateKey: privateKey, jsonData: json, version: version);
      expect(result.length, 130);
    });
  });

  group('typed data model', () {
    test('EIP712TypedData toJson', () {
      EIP712TypedData data =
          new EIP712TypedData(name: 'name', type: 'string', value: 'string');
      data.toJson();
    });

    test('TypedDataField toJson', () {
      TypedDataField(name: "test", type: "test").toJson();
    });
  });
}
