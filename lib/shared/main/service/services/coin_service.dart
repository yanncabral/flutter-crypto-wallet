import 'package:transfero/shared/data/repository/coin/coin_repository.dart';
import 'package:transfero/shared/domain/error/domain_error.dart';
import 'package:transfero/shared/domain/entities/coin_price_history.dart';
import 'package:transfero/shared/domain/entities/coin.dart';
import 'package:dartz/dartz.dart';

import 'package:transfero/shared/domain/usecases/get_coin_history.dart';
import 'package:transfero/shared/infra/shared_preferences/shared_preferences.dart';
import 'package:transfero/shared/main/service/service.dart';

// A simple facade implementation using mixin
class CoinService with SharedPreferences implements Service, CoinRepository {
  static late final CoinRepository instance = CoinRepository();

  @override
  Future<void> ensureInitialized() {
    return instance.ensureInitialized();
  }

  @override
  Future<Either<DomainError, Coin>> getCoinBy(
      {required String code, String from = "USD"}) {
    return instance.getCoinBy(code: code, from: from);
  }

  @override
  Future<Either<DomainError, Iterable<CoinPrice>>> getCoinHistory({
    required String asset,
    DateTime? start,
    DateTime? end,
    int limit = 100,
    CoinPriceHistoryPeriod period = CoinPriceHistoryPeriod.hourly,
    String quote = "USD",
  }) {
    return instance.getCoinHistory(
      asset: asset,
      end: end,
      start: start,
      limit: limit,
      period: period,
      quote: quote,
    );
  }

  @override
  Future<Either<DomainError, Iterable<Coin>>> listCoins() {
    return instance.listCoins();
  }
}
