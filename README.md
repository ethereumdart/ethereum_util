# ethereum_util

**This project is a work in progress.**

Porting Ethereum utilities from Javascript to Dart:

- https://github.com/ethjs/ethjs-util/
- https://github.com/ethereumjs/ethereumjs-util
- https://github.com/simolus3/web3dart/
- https://github.com/maxholman/rlp
- https://github.com/MetaMask/eth-sig-util
- https://github.com/ethereumjs/ethereumjs-abi
- https://github.com/ethereumjs/ethereumjs-wallet

Check [test](./test) folder for usage.

---------

## Sign EIP 1559 transaction
```
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:ethereum_util/src/eip1559Transaction.dart';

void main() {
  TxData txData = new TxData(
    nonce: 1,
    maxPriorityFeePerGas: 10000,
    maxFeePerGas: 1000000,
    gasLimit: 21000,
    to: '0xfd79200d598a5a875ea30f0b4172aa525caaba53',
    value: 1000000000
  );

  // Match the network. e.g. Mainnet: 1, ropsten: 3.
  TxNetwork txNetwork = new TxNetwork(chainId: 3);

  var tx = new Eip1559Transaction(txData, txNetwork);
  // var data = tx.getMessageToSign();
  // print(hex.encode(data));

  // Sign with your private key.
  var result = tx.sign(privateKey);
  print(hex.encode(result));
}

```

## Sign legacy transaction
```
import 'dart:typed_data';
import 'package:ethereum_util/src/legacyTransaction.dart';

void main() {
  TxData txData = new TxData(
    nonce: 46,
    gasPrice: 5000000000,
    gasLimit: 21000,
    to: '0x7fD1aA2b64d8ACfC85be1eA2DaF535f8821D0B6a',
    value: 1000000000000000
  );

  // Match the network. e.g. Mainnet: 1, ropsten: 3.
  TxNetwork txNetwork = new TxNetwork(chainId: 56);

  var tx = new LegacyTransaction(txData, txNetwork);
  var data = tx.serialize();

  // Sign with your private key.
  var result = tx.sign(Uint8List.fromList(privateKey));
}
```