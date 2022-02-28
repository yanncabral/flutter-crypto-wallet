import 'package:transfero/shared/domain/usecases/get_coin_history.dart';

extension CoinApiCoinPriceHistoryPeriod on CoinPriceHistoryPeriod {
  String toApi() {
    switch (this) {
      case CoinPriceHistoryPeriod.secondly:
        return "1SEC";
      case CoinPriceHistoryPeriod.minutly:
        return "1MIN";
      case CoinPriceHistoryPeriod.hourly:
        return "1HRS";
      case CoinPriceHistoryPeriod.daily:
        return "1DAY";
      case CoinPriceHistoryPeriod.weekly:
        return "7DAY";
    }
  }
}
