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
}

class TxNetwork {
  int chainId;

  TxNetwork({required this.chainId});
}