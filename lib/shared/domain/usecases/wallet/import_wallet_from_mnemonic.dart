import 'package:dartz/dartz.dart';
import 'package:transfero/shared/domain/entities/wallet.dart';
import 'package:transfero/shared/domain/error/domain_error.dart';

abstract class ImportWalletFromMnemonic {
  Future<Either<DomainError, Wallet>> fromMnemonic(String mnemonic);
}
