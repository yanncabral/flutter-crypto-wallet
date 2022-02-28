import 'package:dartz/dartz.dart';
import 'package:transfero/shared/domain/entities/coin.dart';
import 'package:transfero/shared/domain/error/domain_error.dart';

abstract class GetAllCoins {
  Future<Either<DomainError, Iterable<Coin>>> listCoins();
}
