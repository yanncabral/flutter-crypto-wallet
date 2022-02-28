import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:queue/queue.dart';
import 'package:retry/retry.dart';
import 'package:transfero/shared/data/repository/repository.dart';

import 'package:transfero/shared/domain/entities/coin.dart';
import 'package:transfero/shared/domain/entities/coin_price_history.dart';
import 'package:transfero/shared/domain/error/domain_error.dart';

import 'package:transfero/shared/domain/usecases/get_all_coins.dart';
import 'package:transfero/shared/domain/usecases/get_coin_by_code.dart';
import 'package:transfero/shared/domain/usecases/get_coin_history.dart';

import 'package:transfero/shared/external/model/coinapi/coinapi_coin_price_model.dart';
import 'package:transfero/shared/external/model/coinapi/coinapi_price_history_period.dart';
import 'package:transfero/shared/infra/shared_preferences/shared_preferences.dart';

import 'package:transfero/shared/main/initialize/initialize.dart';

const baseUri = "https://rest.coinapi.io/";

class CoinRepository
    with SharedPreferences, ApplicationInitializer
    implements Repository, GetCoinByCode, GetCoinHistory, GetAllCoins {
  // final Map<String, Future<http.Response>> _cache = {};

  late final _jobQueue = Queue(
    delay: const Duration(milliseconds: 500),
  ); // Due to api free tier concurrency limitation

  Future<http.Response> _get(Uri uri) async {
    await ensureInitialized();
    final apiKey = dotenv.get("COINAPI_KEY");
    final cacheKey = uri.toString(); // using the uri as memory cache key

    return retry(() async {
      final result = await read(key: cacheKey).then((value) => value.fold(
            (error) async {
              final result = await _jobQueue.add(() => http.get(
                    uri,
                    headers: {"X-CoinAPI-Key": apiKey},
                  ));

              return result;
            },
            (value) => Future.value(http.Response(value, 200)),
          ));

      // final result = await _jobQueue.add(
      //   () => (_cache[cacheKey] ??= http.get(
      //     uri,
      //     headers: {"X-CoinAPI-Key": apiKey},
      //   )),
      // );

      if (result.statusCode == 429) {
        throw Exception();
      } else {
        await write(key: cacheKey, value: result.body);
        return result;
      }
    });
  }

  @override
  Future<Either<DomainError, Coin>> getCoinBy({
    required String code,
    String from = "BRL",
  }) async {
    final uri = Uri(
      scheme: 'https',
      host: 'rest.coinapi.io',
      path: "v1/exchangerate/$code/$from",
    );

    final response = await _get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Right(
        Coin(
          imageUrl: "",
          name: code,
          code: code,
          price: body["rate"],
        ),
      );
    } else {
      return const Left(DomainError.unexpected);
    }
  }

  @override
  Future<Either<DomainError, Iterable<CoinPrice>>> getCoinHistory({
    required String asset,
    DateTime? start,
    DateTime? end,
    int limit = 100,
    CoinPriceHistoryPeriod period = CoinPriceHistoryPeriod.hourly,
    String quote = "BRL",
  }) async {
    start ??= DateTime.now().subtract(const Duration(days: 30));
    end ??= DateTime.now();

    final uri = Uri(
      scheme: 'https',
      host: 'rest.coinapi.io',
      path: 'v1/exchangerate/$asset/$quote/history',
      queryParameters: <String, String>{
        "period_id": period.toApi(),
        "time_start": DateTime(
          start.year,
          start.month,
          start.day,
        ).toIso8601String(),
        "time_end": DateTime(
          end.year,
          end.month,
          end.day,
        ).toIso8601String(),
        "limit": limit.toString(),
      },
    );

    final response = await _get(uri);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body) as List<dynamic>;
      return Right(body.map((e) => CoinApiCoinPriceModel.from(json: e)));
    } else {
      return const Left(DomainError.unexpected);
    }
  }

  @override
  Future<Either<DomainError, Iterable<Coin>>> listCoins() async {
    const dataEndpoint = "/v1/assets";
    final dataUri = Uri(
      scheme: 'https',
      host: 'rest.coinapi.io',
      path: dataEndpoint,
      queryParameters: <String, String>{
        "filter_asset_id": "BTC;ETH;ADA;BRZ;DAI;LTC",
      },
    );

    const iconsEndpoint = "/v1/assets/icons/64";

    final iconsUri = Uri(
      scheme: 'https',
      host: 'rest.coinapi.io',
      path: iconsEndpoint,
    );

    final responses = [await _get(dataUri), await _get(iconsUri)];

    if (responses.every((e) => e.statusCode == 200)) {
      final assets = jsonDecode(responses[0].body) as List<dynamic>;
      final Map<String, String> icons = {};
      (jsonDecode(responses[1].body) as List<dynamic>)
          .forEach((e) => icons[e["asset_id"]] = e["url"]);

      return Right(
        assets.map(
          (e) => Coin(
            imageUrl: icons[e["asset_id"]] ?? "",
            code: e["asset_id"],
            name: e["name"],
            price: e["price_usd"] ?? 1.0,
          ),
        ),
      );
    } else {
      return const Left(DomainError.unexpected);
    }
  }
}
