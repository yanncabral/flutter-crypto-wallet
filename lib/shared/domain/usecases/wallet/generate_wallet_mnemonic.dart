import 'package:dartz/dartz.dart';
import 'package:transfero/shared/domain/entities/wallet.dart';

enum ConfirmationError {
  invalid,
  incorrect,
  unexpected,
}

typedef ConfirmationFunction = Tuple2<String,
    Future<Either<ConfirmationError, Wallet>> Function(String confirmation)>;

abstract class GenerateWalletMnemonic {
  ConfirmationFunction generateWalletMnemonic();
}
