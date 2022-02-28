import 'package:transfero/shared/domain/entities/network_type.dart';
import 'package:transfero/shared/domain/entities/wallet.dart';

extension WalletModel on Wallet {
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "address": address,
      "ethBalance": ethBalance.toString(),
      "network": network.index,
      "privateKey": privateKey,
      "tokenBalance": tokenBalance.toString(),
      "mnemonic": mnemonic,
    };
  }

  static Wallet fromJson(Map<String, dynamic> json) {
    return Wallet(
      mnemonic: json["mnemonic"],
      network: NetworkType.values[json["network"] as int],
      address: json["address"],
      privateKey: json["privateKey"],
      tokenBalance: BigInt.parse(json["tokenBalance"] as String),
      ethBalance: BigInt.parse(json["ethBalance"] as String),
    );
  }
}
