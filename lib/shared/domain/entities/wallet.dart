import 'network_type.dart';

class Wallet {
  final NetworkType network;
  final String address;
  final String privateKey;
  final BigInt tokenBalance;
  final BigInt ethBalance;
  final String mnemonic;

  Wallet({
    required this.mnemonic,
    required this.network,
    required this.address,
    required this.privateKey,
    required this.tokenBalance,
    required this.ethBalance,
  });
}
