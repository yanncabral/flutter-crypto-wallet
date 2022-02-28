import 'package:transfero/shared/domain/entities/coin_price_history.dart';

extension CoinApiCoinPriceModel on CoinPrice {
  static CoinPrice from({required Map<String, dynamic> json}) {
    return CoinPrice(
      start: DateTime.parse(json["time_period_start"] as String),
      end: DateTime.parse(json["time_period_end"] as String),
      open: json["rate_open"] as double,
      high: json["rate_high"] as double,
      close: json["rate_low"] as double,
      low: json["rate_close"] as double,
    );
  }
}
