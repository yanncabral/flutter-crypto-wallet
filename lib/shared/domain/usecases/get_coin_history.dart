import 'package:dartz/dartz.dart';
import 'package:transfero/shared/domain/entities/coin_price_history.dart';
import 'package:transfero/shared/domain/error/domain_error.dart';

enum CoinPriceHistoryPeriod {
  secondly,
  minutly,
  hourly,
  daily,
  weekly,
}

abstract class GetCoinHistory {
  Future<Either<DomainError, Iterable<CoinPrice>>> getCoinHistory({
    required String asset,
    DateTime? start,
    DateTime? end,
    int limit = 100,
    CoinPriceHistoryPeriod period = CoinPriceHistoryPeriod.hourly,
    String quote = "BRL",
  });
}
