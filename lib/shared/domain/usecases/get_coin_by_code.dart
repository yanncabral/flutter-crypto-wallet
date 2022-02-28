import 'package:dartz/dartz.dart';
import 'package:transfero/shared/domain/entities/coin.dart';
import 'package:transfero/shared/domain/error/domain_error.dart';

abstract class GetCoinByCode {
  Future<Either<DomainError, Coin>> getCoinBy({
    required String code,
    String from = "BRL",
  });
}
