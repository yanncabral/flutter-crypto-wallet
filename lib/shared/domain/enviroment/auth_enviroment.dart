import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';

import 'package:transfero/shared/domain/entities/wallet.dart';
import 'package:transfero/shared/domain/error/domain_error.dart';
import 'package:transfero/shared/external/model/wallet/wallet.dart';

import 'package:transfero/shared/infra/shared_preferences/shared_preferences.dart';

class AuthEnviroment with SharedPreferences {
  static late final _instance = AuthEnviroment._();

  AuthEnviroment._() {
    _controller = StreamController<Wallet?>.broadcast(onListen: () {
      getCurrentWallet()
          .then((value) => value.fold((l) => null, (r) => r))
          .then(_controller.add);
    });
  }

  factory AuthEnviroment() => _instance;

  late final StreamController<Wallet?> _controller;

  Stream<Wallet?> get state => _controller.stream;

  Future<Either<DomainError, Unit>> setCurrentWallet(Wallet wallet) async {
    try {
      await write(
        key: "currentWallet",
        value: jsonEncode(wallet.toJson()),
      );
      _controller.add(wallet);

      return const Right(unit);
    } catch (e) {
      return const Left(DomainError.unexpected);
    }
  }

  Future<Either<DomainError, Wallet>> getCurrentWallet() async {
    final raw = await read(key: "currentWallet");
    return raw.fold(
      (sharedPreferencesError) => const Left(DomainError.unexpected),
      (data) => Right(WalletModel.fromJson(jsonDecode(data))),
    );
  }

  void signOut() async {
    await delete(key: "currentWallet");
    _controller.add(null);
  }
}
