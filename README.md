# Ethereum Util for Dart 👋

[![pub package](https://img.shields.io/pub/v/ethereum_util.svg)](https://pub.dev/packages/ethereum_util)
[![build status](https://github.com/ethereumdart/ethereum_util/actions/workflows/dart.yml/badge.svg)](https://github.com/ethereumdart/ethereum_util/actions/workflows/dart.yml)

A collection of utility functions for Ethereum and other blockchains, ported from JavaScript to Dart. This library is a work in progress and aims to provide a comprehensive set of tools for Dart developers working with Ethereum.

## Features ✨

*   Sign EIP-1559 and legacy transactions
*   RLP encoding and decoding
*   Ethereum address and public key utilities
*   Hashing functions (keccak256, sha256)
*   Signature utilities (ecrecover, toRpcSig)
*   Typed data signing (EIP-712)
*   Support for other coins like Polkadot (DOT), Sui (SUI), and Ripple (XRP)

## Installation 📦

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  ethereum_util: ^1.5.1
```

Then run `pub get` or `flutter pub get`.

## Usage 🚀

### Sign an EIP-1559 Transaction

```dart
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:ethereum_util/src/eip1559Transaction.dart';

void main() {
  final txData = TxData(
    nonce: 1,
    maxPriorityFeePerGas: 10000,
    maxFeePerGas: 1000000,
    gasLimit: 21000,
    to: '0xfd79200d598a5a875ea30f0b4172aa525caaba53',
    value: 1000000000,
  );

  // Match the network. e.g. Mainnet: 1, Ropsten: 3.
  final txNetwork = TxNetwork(chainId: 3);

  final tx = Eip1559Transaction(txData, txNetwork);

  // Sign with your private key.
  // final privateKey = ...;
  // final result = tx.sign(privateKey);
  // print(hex.encode(result));
}
```

### Sign a Legacy Transaction

```dart
import 'dart:typed_data';
import 'package:ethereum_util/src/legacyTransaction.dart';

void main() {
  final txData = TxData(
    nonce: 46,
    gasPrice: 5000000000,
    gasLimit: 21000,
    to: '0x7fD1aA2b64d8ACfC85be1eA2DaF535f8821D0B6a',
    value: 1000000000000000,
  );

  // Match the network. e.g. Mainnet: 1, Ropsten: 3, BSC: 56.
  final txNetwork = TxNetwork(chainId: 56);

  final tx = LegacyTransaction(txData, txNetwork);

  // Sign with your private key.
  // final privateKey = ...;
  // final result = tx.sign(Uint8List.fromList(privateKey));
}
```

For more examples, please check the `test` directory.

## Testing 🧪

To run the tests for this package, use the following command:

```bash
dart test
```

## Contributing 🤝

Contributions are welcome! Please feel free to open an issue or submit a pull request on our [GitHub repository](https://github.com/ethereumdart/ethereum_util).

## License 📝

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.