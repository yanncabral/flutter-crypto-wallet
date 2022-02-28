import 'dart:async';

import 'package:bip39/bip39.dart' as bip39;
import 'package:ed25519_hd_key/ed25519_hd_key.dart';
import 'package:hex/hex.dart';
import 'package:convert/convert.dart';
import 'package:transfero/shared/data/repository/repository.dart';
import 'package:transfero/shared/data/service/contract_service.dart';
import 'package:transfero/shared/domain/entities/network_type.dart';

import 'package:transfero/shared/domain/error/domain_error.dart';
import 'package:transfero/shared/domain/entities/wallet.dart';
import 'package:dartz/dartz.dart';
import 'package:transfero/shared/domain/usecases/wallet/generate_wallet_mnemonic.dart';

import 'package:transfero/shared/domain/usecases/wallet/import_wallet_from_mnemonic.dart';

import 'package:transfero/shared/infra/shared_preferences/shared_preferences.dart';

import 'package:web3dart/web3dart.dart' hide Wallet;

class WalletRepository
    with SharedPreferences
    implements Repository, ImportWalletFromMnemonic, GenerateWalletMnemonic {
  final ContractService _contract;

  WalletRepository(this._contract);

  final _controller = StreamController<Wallet>.broadcast();
  Stream<Wallet> subscribe(Wallet wallet) {
    _contract.listenTransfer((from, to, value) {
      fromMnemonic(wallet.mnemonic).then(
        (value) => value.fold(
          (l) => null,
          (r) => _controller.add(r),
        ),
      );
    });
    return _controller.stream;
  }

  Future<String?> send(
      String privateKey, EthereumAddress receiver, BigInt amount,
      {TransferEvent? onTransfer, Function(String exeception)? onError}) {
    return _contract.send(
      privateKey,
      receiver,
      amount,
      onError: onError,
      onTransfer: onTransfer,
    );
  }

  Future<EthereumAddress> _getPublicAddress(String privateKey) async {
    final private = EthPrivateKey.fromHex(privateKey);
    final address = await private.extractAddress();

    return address;
  }

  Future<String> _getPrivateKey(String mnemonic) async {
    final seed = bip39.mnemonicToSeedHex(mnemonic);
    final master = await ED25519_HD_KEY.getMasterKeyFromSeed(
      hex.decode(seed),
      masterSecret: 'Bitcoin seed',
    );
    final privateKey = HEX.encode(master.key);
    return privateKey;
  }

  @override
  Future<Either<DomainError, Wallet>> fromMnemonic(String mnemonic) async {
    // final cryptMnemonic = bip39.mnemonicToEntropy(mnemonic);
    final privateKey = await _getPrivateKey(mnemonic);
    final address = await _getPublicAddress(privateKey);

    final tokenBalance = await _contract.getTokenBalance(address);
    final wallet = Wallet(
      mnemonic: mnemonic,
      network: NetworkType.etherium,
      address: address.hex,
      privateKey: privateKey,
      tokenBalance: tokenBalance,
      ethBalance: BigInt.zero,
    );

    return Right(wallet);
  }

  String _generateMnemonic() {
    return bip39.generateMnemonic();
  }

  @override
  ConfirmationFunction generateWalletMnemonic() {
    final mnemonic = _generateMnemonic();

    return Tuple2(mnemonic, ((confirmation) async {
      if (confirmation.isEmpty ||
          confirmation
                  .split(" ")
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .length !=
              12) {
        return const Left(ConfirmationError.invalid);
      } else if (confirmation != mnemonic) {
        return const Left(ConfirmationError.incorrect);
      } else {
        final result = await fromMnemonic(confirmation).then(
          (value) => value.fold((l) => null, (r) => r),
        );
        if (result != null) {
          return Right(result);
        } else {
          return const Left(ConfirmationError.unexpected);
        }
      }
    }));
  }
}
