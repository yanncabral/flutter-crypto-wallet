import 'package:dartz/dartz.dart';
import 'package:transfero/shared/domain/entities/coin.dart';
import 'package:transfero/shared/domain/error/domain_error.dart';

abstract class GetExchangeRate {
  Future<Either<DomainError, double>> getExchangeRate({
    required Coin from,
    required Coin to,
  });
}
