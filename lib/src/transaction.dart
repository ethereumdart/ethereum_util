class TxData {
  int nonce;
  int gasLimit;
  int maxPriorityFeePerGas;
  int maxFeePerGas;
  int gasPrice;
  String to;
  int value;
  String data;
  int? v;
  BigInt? r;
  BigInt? s;

  TxData({
    required this.nonce,
    required this.gasLimit,
    this.maxPriorityFeePerGas = 0,
    this.maxFeePerGas = 0,
    this.gasPrice = 0,
    this.to = '',
    this.value = 0,
    this.data = '',
    this.v,
    this.r,
    this.s
  });

  set setNonce(int item) => nonce = item;
  set setGasLimit(int item) => gasLimit = item;
  set setMaxPriorityFeePerGas(int item) => maxPriorityFeePerGas = item;
  set setMaxFeePerGas(int item) => maxFeePerGas = item;
  set setGasPrice(int item) => gasPrice = item;
  set setTo(String item) => to = item;
  set setValue(int item) => value = item;
  set setData(String item) => data = item;
}

class TxNetwork {
  int chainId;

  TxNetwork({required this.chainId});
}