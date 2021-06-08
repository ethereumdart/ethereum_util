import 'dart:convert';
import 'dart:typed_data';

import 'package:ethereum_util/src/bytes.dart';
import 'package:ethereum_util/src/signature.dart';
import 'package:ethereum_util/src/typed_data.dart';
import 'package:test/test.dart';

final TypedData typedData = TypedData(
    types: {
      "EIP712Domain": [
        TypedDataField(name: "name", type: "string"),
        TypedDataField(name: "version", type: "string"),
        TypedDataField(name: "chainId", type: "uint256"),
        TypedDataField(name: "verifyingContract", type: "address")
      ],
      "Person": [
        TypedDataField(name: "name", type: "string"),
        TypedDataField(name: "wallet", type: "address")
      ],
      "Mail": [
        TypedDataField(name: "from", type: "Person"),
        TypedDataField(name: "to", type: "Person"),
        TypedDataField(name: "contents", type: "string")
      ]
    },
    primaryType: "Mail",
    domain: EIP712Domain(
        name: "Ether Mail",
        version: "1",
        chainId: 1,
        verifyingContract: "0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"),
    message: {
      "from": {
        "name": "Cow",
        "wallet": "0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"
      },
      "to": {
        "name": "Bob",
        "wallet": "0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"
      },
      "contents": "Hello, Bob!"
    });

void main() {
  test('signedTypeData', () {
    var privateKey = sha3(Uint8List.fromList(utf8.encode('cow')));
    var address = privateKeyToAddress(privateKey);
    var sig = signTypedData(privateKey, MsgParams(data: typedData));

    expect(TypedDataUtils.encodeType('Mail', typedData.types),
        'Mail(Person from,Person to,string contents)Person(string name,address wallet)');
    expect(bufferToHex(TypedDataUtils.hashType('Mail', typedData.types)),
        '0xa0cedeb2dc280ba39b857546d74f5549c3a1d7bdc2dd96bf881f76108e23dac2');
    expect(
        bufferToHex(TypedDataUtils.encodeData(
            typedData.primaryType, typedData.message, typedData.types)),
        '0xa0cedeb2dc280ba39b857546d74f5549c3a1d7bdc2dd96bf881f76108e23dac2fc71e5fa27ff56c350aa531bc129ebdf613b772b6604664f5d8dbe21b85eb0c8cd54f074a4af31b4411ff6a60c9719dbd559c221c8ac3492d9d872b041d703d1b5aadf3154a261abdd9086fc627b61efca26ae5702701d05cd2305f7c52a2fc8');
    expect(
        bufferToHex(TypedDataUtils.hashStruct(
            typedData.primaryType, typedData.message, typedData.types)),
        '0xc52c0ee5d84264471806290a3f2c4cecfc5490626bf912d01f240d7a274b371e');
    expect(
        bufferToHex(TypedDataUtils.hashStruct(
            'EIP712Domain', typedData.domain, typedData.types)),
        '0xf2cee375fa42b42143804025fc449deafd50cc031ca257e0b194a650a912090f');
    expect(bufferToHex(TypedDataUtils.sign(typedData)),
        '0xbe609aee343fb3c4b28e1df9e632fca64fcfaede20f02e86244efddf30957bd2');
    expect(bufferToHex(address), '0xcd2a3d9f938e13cd947ec05abc7fe734df8dd826');
    expect(sig,
        '0x4355c47d63924e8a72e509b65029052eb6c299d53a04e167c5775fd466751c9d07299936d304c153f6443dfa05f40ff007d72911b6f72307f996231605b915621c');
  });

  test('normalize address adds hex prefix', () {
    var initial = 'A06599BD35921CfB5B71B4BE3869740385b0B306';
    var result = normalize(initial);
    expect(result, '0x' + initial.toLowerCase());
  });

  test('normalize an integer converts to byte-pair hex', () {
    var initial = 1;
    var result = normalize(initial);
    expect(result, '0x01');
  });

  test('normalize an unsupported type throws', () {
    expect(() => normalize({}), throwsArgumentError);
  });

  test('toJson', () {
    expect(jsonEncode(typedData.toJson()),
        r'{"types":{"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}],"Person":[{"name":"name","type":"string"},{"name":"wallet","type":"address"}],"Mail":[{"name":"from","type":"Person"},{"name":"to","type":"Person"},{"name":"contents","type":"string"}]},"primaryType":"Mail","domain":{"name":"Ether Mail","version":"1","chainId":1,"verifyingContract":"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"},"message":{"from":{"name":"Cow","wallet":"0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"},"to":{"name":"Bob","wallet":"0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"},"contents":"Hello, Bob!"}}');
  });
}
