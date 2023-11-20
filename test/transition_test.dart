import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:convert/convert.dart' show hex;

import 'package:ethereum_util/src/eip1559Transaction.dart';
import 'package:ethereum_util/src/legacyTransaction.dart';
import 'package:ethereum_util/src/transaction.dart';

void main() {
  var ecprivkey = hex.decode(
      '3c9229289a6125f7fdf1885a77bb12c37a8d3b4962d936f7e3084dece32a3ca1');
  TxNetwork txNetwork = new TxNetwork(chainId: 1);
  TxData txData = TxData(
    nonce: 0,
    gasLimit: 21000,
    value: BigInt.from(10),
    to: '0x1234567890abcdef',
  );

  group('EIP1559 transition', () {
    Eip1559Transaction eip1559transaction =
        new Eip1559Transaction(txData, txNetwork);

    test('sign', () {
      final result = eip1559transaction.sign(Uint8List.fromList(ecprivkey));
      expect(result.length, 89);
    });

    test('serialize', () {
      final result = eip1559transaction.serialize();
      expect(result.length, 89);
    });
  });

  group('legacy transition', () {
    LegacyTransaction legacyTransaction =
        new LegacyTransaction(txData, txNetwork);

    test('sign', () {
      final result = legacyTransaction.sign(Uint8List.fromList(ecprivkey));
      expect(result.length, 85);
    });

    test('serialize', () {
      final result = legacyTransaction.serialize();
      expect(result.length, 85);
    });
  });

  group('transition', () {
    const nonce = 1;
    const gasLimit = 22000;
    const maxPriorityFeePerGas = 1;
    const maxFeePerGas = 1;
    const gasPrice = 1;
    const to = '0x1234567890abcdefG';
    const data = 'data';
    final value = BigInt.from(11);

    test('set nonce', () {
      txData.setNonce = nonce;
      expect(txData.nonce, nonce);
    });

    test('set gasLimit', () {
      txData.setGasLimit = gasLimit;
      expect(txData.gasLimit, gasLimit);
    });

    test('set maxPriorityFeePerGas', () {
      txData.setMaxPriorityFeePerGas = maxPriorityFeePerGas;
      expect(txData.maxPriorityFeePerGas, maxPriorityFeePerGas);
    });

    test('set maxFeePerGas', () {
      txData.setMaxFeePerGas = maxFeePerGas;
      expect(txData.maxFeePerGas, maxFeePerGas);
    });

    test('set gasPrice', () {
      txData.setGasPrice = gasPrice;
      expect(txData.gasPrice, gasPrice);
    });

    test('set to', () {
      txData.setTo = to;
      expect(txData.to, to);
    });

    test('set data', () {
      txData.setData = data;
      expect(txData.data, data);
    });

    test('set value', () {
      txData.setValue = value;
      expect(txData.value, value);
    });
  });
}
