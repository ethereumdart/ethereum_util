import 'dart:convert';
import 'dart:typed_data';

import 'package:test/test.dart';

import 'package:ethereum_util/src/bytes.dart';
import 'package:ethereum_util/src/signature.dart';
import 'package:ethereum_util/src/typed_data.dart';

final TypedData typedData = TypedData(
  types: {
    'EIP712Domain': [
      TypedDataField(name: 'name', type: 'string'),
      TypedDataField(name: 'version', type: 'string'),
      TypedDataField(name: 'chainId', type: 'uint256'),
      TypedDataField(name: 'verifyingContract', type: 'address')
    ],
    'Person': [
      TypedDataField(name: 'name', type: 'string'),
      TypedDataField(name: 'wallet', type: 'address')
    ],
    'Mail': [
      TypedDataField(name: 'from', type: 'Person'),
      TypedDataField(name: 'to', type: 'Person'),
      TypedDataField(name: 'contents', type: 'string')
    ]
  },
  primaryType: 'Mail',
  domain: EIP712Domain(
    name: 'Ether Mail',
    version: '1',
    chainId: 1,
    verifyingContract: '0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC'
  ),
  message: {
    'from': {
      'name': 'Cow',
      'wallet': '0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826'
    },
    'to': {
      'name': 'Bob',
      'wallet': '0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB'
    },
    'contents': 'Hello, Bob!'
  }
);

void main() {
  test('signedTypeData', () {
    var privateKey = sha3(Uint8List.fromList(utf8.encode('cow')));
    var address = privateKeyToAddress(privateKey);
    var sig = signTypedData(privateKey, MsgParams(data: typedData));

    expect(TypedDataUtils.encodeType('Mail', typedData.types!), 'Mail(Person from,Person to,string contents)Person(string name,address wallet)');
    expect(bufferToHex(TypedDataUtils.hashType('Mail', typedData.types)), '0xda8b122f9405015467a4c2d2b5d72f976d0dcd07f39d640df998cb582f24622b');
    expect(
      bufferToHex(TypedDataUtils.encodeData( typedData.primaryType, typedData.message, typedData.types)),
      '0xda8b122f9405015467a4c2d2b5d72f976d0dcd07f39d640df998cb582f24622b960f5eae4594a79302a6a52f4a0d0a13dd4cc97a0d9a2d665958cd72ac27928776c77f5f84ab3ca0e9759568cc0a6f75998410e561dc8ea91bff7d2a71f1a932b58543c145f315ad2c9210b45c29c13e6c9fc5396a140d3b07f766925fda360e'
    );
    expect(
      bufferToHex(TypedDataUtils.hashStruct(typedData.primaryType, typedData.message, typedData.types)),
      '0xf4db1703342472a4aadbcc1b92facbe9760a0e370f66849372a2cb76e84144da'
    );
    expect(
      bufferToHex(TypedDataUtils.hashStruct('EIP712Domain', typedData.domain, typedData.types)),
      '0xd7f1ff1a053fee282f99985f25b0099cbb1d7e3d978684ccefae2ded8ec94a7b'
    );
    expect(bufferToHex(TypedDataUtils.sign(typedData)), '0x65531c7ceec752cdd65c8614a59b3c1d85a657a77799cb38475dcef1b834f348');
    expect(bufferToHex(address), '0x744b51362f1deae679b55dbf88e9c5a9dfa7bc48');
    expect(sig, '0xf0a3f930ef09ce1fa3085502b2d40a8dde6fecfcfc984d4912d0a9919da858e7642d71b98e924c87c56385a3111286f52ca3b57eb35045ed0fb40a76340a91df1b');
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
    expect(
      jsonEncode(typedData.toJson()),
      r'{"types":{"EIP712Domain":[{"name":"name","type":"string"},{"name":"version","type":"string"},{"name":"chainId","type":"uint256"},{"name":"verifyingContract","type":"address"}],"Person":[{"name":"name","type":"string"},{"name":"wallet","type":"address"}],"Mail":[{"name":"from","type":"Person"},{"name":"to","type":"Person"},{"name":"contents","type":"string"}]},"primaryType":"Mail","domain":{"name":"Ether Mail","version":"1","chainId":1,"verifyingContract":"0xCcCCccccCCCCcCCCCCCcCcCccCcCCCcCcccccccC"},"message":{"from":{"name":"Cow","wallet":"0xCD2a3d9F938E13CD947Ec05AbC7FE734Df8DD826"},"to":{"name":"Bob","wallet":"0xbBbBBBBbbBBBbbbBbbBbbbbBBbBbbbbBbBbbBBbB"},"contents":"Hello, Bob!"}}'
    );
  });
}
