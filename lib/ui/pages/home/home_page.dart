import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:motion_toast/resources/arrays.dart';
import 'package:transfero/shared/data/repository/coin/coin_repository.dart';
import 'package:transfero/shared/data/repository/wallet/wallet_repository.dart';
import 'package:transfero/shared/domain/entities/coin.dart';
import 'package:transfero/shared/domain/entities/coin_price_history.dart';
import 'package:transfero/shared/domain/entities/network_type.dart';
import 'package:transfero/shared/domain/entities/wallet.dart';

import 'package:transfero/shared/domain/usecases/get_coin_history.dart';
import 'package:transfero/shared/infra/locator/contract_locator.dart';
import 'package:transfero/shared/infra/network_types_settings/network_types_settings.dart';
import 'package:transfero/shared/main/service/services/coin_service.dart';
import 'package:transfero/shared/utils/eth_amount_formatter.dart';
import 'package:transfero/ui/hooks/use_auth_enviroment.dart';
import 'package:transfero/ui/pages/onboarding/onboarding_page.dart';
import 'package:web3dart/web3dart.dart' hide Wallet;

final errorToast = MotionToast.error(
  title: const Text("Oops.."),
  description:
      const Text("We got a error due the api free tier limit. Try again."),
  dismissable: true,
  position: MOTION_TOAST_POSITION.top,
  animationType: ANIMATION.fromTop,
);

AsyncSnapshot<Wallet?> useWallet({required String mnemonic}) {
  final future = useMemoized(() =>
      ContractLocator.createInstance(NetworkType.etherium.settings)
          .then((value) => WalletRepository(value))
          .then((value) => value.fromMnemonic(mnemonic))
          .then((value) => value.fold((l) => null, (r) => r)));

  return useFuture(future);
}

CoinRepository useCoinService() {
  return useMemoized(() => CoinService.instance);
}

class HomePage extends HookWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final allCoins = useState<List<Coin>?>([]);
    final authEnviroment = useAuthEnviroment();
    final repository = useWalletRepository();

    final currentWallet = useFuture(authEnviroment.getCurrentWallet().then(
          (value) => value.fold((error) => null, (wallet) => wallet),
        ));

    final coinService = useCoinService();

    useEffect(() {
      coinService.listCoins().then((value) {
        value.fold(
          (error) => errorToast.show(context),
          (coins) => allCoins.value = coins.toList(),
        );
      });
      return null;
    }, []);

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            systemOverlayStyle: SystemUiOverlayStyle.light,
            pinned: true,
            centerTitle: true,
            leading: IconButton(
                onPressed: () async {
                  final r = await repository;

                  final mnemonic = currentWallet.data?.mnemonic;
                  if (mnemonic != null) {
                    final updated = await r.fromMnemonic(mnemonic);
                    updated.fold(
                      (l) => null,
                      (wallet) => authEnviroment.setCurrentWallet(wallet),
                    );
                  }
                },
                icon: const Icon(Icons.refresh)),
            actions: [
              IconButton(
                  onPressed: () {
                    authEnviroment.signOut();
                  },
                  icon: const Icon(Icons.logout)),
            ],
            title: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: innerBoxIsScrolled
                  ? AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: currentWallet.data == null
                          ? const CircularProgressIndicator()
                          : Text(
                              "¥${EthAmountFormatter(currentWallet.data?.tokenBalance).format()}"),
                    )
                  : Image.asset(
                      "assets/images/logo-2.png",
                      width: 144,
                    ),
            ),
          ),
          SliverStickyHeader(
            sticky: true,
            header: _Balance(wallet: currentWallet.data),
          )
        ],
        body: SingleChildScrollView(
          child: _AllCoinList(coins: allCoins.value ?? []),
        ),
      ),
    );
  }
}

class _Balance extends HookWidget {
  final Wallet? wallet;
  const _Balance({
    Key? key,
    required this.wallet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final addressToSendController = useTextEditingController();
    final repository = useWalletRepository();
    final amountToSendController = useTextEditingController();
    final currentWallet = useStream(useAuthEnviroment().state);
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Balance",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: wallet == null
                ? const CircularProgressIndicator()
                : Text("¥${EthAmountFormatter(wallet?.tokenBalance).format()}"),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  color: Theme.of(context).colorScheme.primary,
                  child: MaterialButton(
                    height: 46,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("Send tokens"),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextField(
                                controller: amountToSendController,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[0-9]'),
                                  ),
                                ],
                                decoration: const InputDecoration(
                                  hintText: "amount",
                                ),
                              ),
                              TextField(
                                controller: addressToSendController,
                                decoration: const InputDecoration(
                                  hintText: "receiver address",
                                ),
                              ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                final wallet = currentWallet.data;
                                if (wallet != null) {
                                  final r = await repository;
                                  r.send(
                                    wallet.privateKey,
                                    EthereumAddress.fromHex(
                                        addressToSendController.text),
                                    BigInt.from(
                                      num.parse(amountToSendController.text),
                                    ),
                                    onTransfer: (from, to, amount) =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                      const SnackBar(
                                        content: Text("Sent"),
                                      ),
                                    ),
                                    onError: (exeception) =>
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                      SnackBar(
                                        content: Text(exeception),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: const Text("Send"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text(
                      "Send",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  child: MaterialButton(
                    height: 46,
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      if (wallet != null) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Your wallet address:"),
                            content: Text(wallet!.address),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  await Clipboard.setData(
                                    ClipboardData(text: wallet!.address),
                                  );
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Address copied!"),
                                    ),
                                  );
                                },
                                child: const Text("Copy"),
                              ),
                            ],
                          ),
                        );
                      }
                    },
                    child: Text(
                      "Receive",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class _AllCoinList extends StatelessWidget {
  final List<Coin> coins;

  const _AllCoinList({Key? key, required this.coins}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            "All Coins",
            style: Theme.of(context).textTheme.headline6?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) => CoinTile(
            coin: coins[index],
          ),
          separatorBuilder: (context, index) => const Divider(),
          itemCount: coins.length,
        ),
      ],
    );
  }
}

class CoinTile extends HookWidget {
  final Coin coin;

  const CoinTile({
    Key? key,
    required this.coin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prices = useState<List<CoinPrice>?>(null);
    final service = useCoinService();
    useEffect(() {
      service
          .getCoinHistory(
        asset: coin.code,
        period: CoinPriceHistoryPeriod.daily,
      )
          .then((data) {
        data.fold(
          (error) => errorToast.show(context),
          (value) => prices.value = value.toList(),
        );
      });

      return null;
    }, []);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 46,
      child: Row(
        children: [
          coin.imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: coin.imageUrl,
                  fit: BoxFit.fitHeight,
                  height: 32,
                )
              : Image.asset(
                  "assets/images/cryptos/BRZ.png",
                  fit: BoxFit.fitHeight,
                  height: 32,
                ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(coin.name),
              Text(
                coin.code,
                style: TextStyle(color: Colors.black.withOpacity(0.5)),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                lineTouchData: LineTouchData(handleBuiltInTouches: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                      isCurved: true,
                      colors: [const Color(0xff4af699)],
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                      spots: prices.value
                          ?.asMap() // enumerate like {0: prices[0], 1: prices[1], ...}
                          .entries // turns into a list like [[0, prices[0], [1, prices[1]]
                          .map((e) => FlSpot(e.key.toDouble(), e.value.close))
                          .toList()),
                ],
              ),
              // swapAnimationDuration: const Duration(milliseconds: 250),
            ),
          ),
          const SizedBox(width: 16),
          if (prices.value?.isNotEmpty == true) ...{
            Text(
              "U\$ ${(prices.value?.last.close ?? 0).toStringAsFixed(2)}",
              style: TextStyle(
                color: Colors.black.withOpacity(0.5),
              ),
            ),
          }
        ],
      ),
    );
  }
}
