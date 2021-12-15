class TxData {
  int nonce;
  int gasLimit;
  int maxPriorityFeePerGas;
  int maxFeePerGas;
  int gasPrice;
  String to;
  int value;
  String data;
  int v;
  BigInt r;
  BigInt s;

  TxData({
    this.nonce,
    this.gasLimit,
    this.maxPriorityFeePerGas,
    this.maxFeePerGas,
    this.gasPrice,
    this.to,
    this.value,
    this.data,
    this.v,
    this.r,
    this.s
  });
}

class TxNetwork {
  int chainId;

  TxNetwork({this.chainId});
}