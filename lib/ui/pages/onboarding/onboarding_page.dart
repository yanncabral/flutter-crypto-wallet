import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:transfero/shared/data/repository/wallet/wallet_repository.dart';
import 'package:transfero/shared/domain/entities/network_type.dart';

import 'package:transfero/shared/infra/locator/contract_locator.dart';
import 'package:transfero/shared/infra/network_types_settings/network_types_settings.dart';
import 'package:transfero/ui/hooks/use_auth_enviroment.dart';

Future<WalletRepository> useWalletRepository() {
  final future = useMemoized(() =>
      ContractLocator.createInstance(NetworkType.etherium.settings)
          .then((value) => WalletRepository(value)));

  return future;
}

class OnboardingPage extends HookWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final futureRepository = useWalletRepository();
    final authEnviroment = useAuthEnviroment();
    final textController = useTextEditingController();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.light,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl:
                "https://images.unsplash.com/photo-1620321023374-d1a68fbc720d?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=2394&q=80",
            fit: BoxFit.fitHeight,
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0, 0.3],
                colors: [
                  Colors.transparent,
                  Theme.of(context).colorScheme.primary.withOpacity(0.7),
                ],
              ),
            ),
          ),
          Column(
            children: [
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: 0.7,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Trade cryptoactives with simplicity and security.",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Start now to invest in your most valuable asset: your freedom.",
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.white,
                          child: InkWell(
                            onTap: () async {
                              final repository = await futureRepository;
                              final tuple = repository.generateWalletMnemonic();
                              final key = tuple.value1;
                              final confirmation = tuple.value2;
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  actions: [
                                    TextButton(
                                      child: const Text("Got it"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        confirmation(key).then(
                                          (result) => result.fold(
                                            (error) => null,
                                            (wallet) async {
                                              await authEnviroment
                                                  .setCurrentWallet(wallet);
                                            },
                                          ),
                                        );
                                      },
                                    )
                                  ],
                                  title: const Text(
                                      "Your new wallet mnemonic key:"),
                                  content: Text(key),
                                ),
                              );
                            },
                            child: const Center(
                              child: ListTile(
                                title: Text(
                                  "Create Wallet",
                                ),
                                trailing: Icon(Icons.chevron_right),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Material(
                          color: Theme.of(context).colorScheme.primary,
                          child: InkWell(
                            onTap: () async {
                              final repository = await futureRepository;
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Type your mnemonic"),
                                  content: TextField(
                                    controller: textController,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: const Text(
                                        "Cancel",
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.of(context).pop();
                                        final result = await repository
                                            .fromMnemonic(textController.text);

                                        result.fold(
                                          (error) =>
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                            const SnackBar(
                                              content: Text("Invalid Mnemonic"),
                                            ),
                                          ),
                                          (wallet) => authEnviroment
                                              .setCurrentWallet(wallet),
                                        );
                                      },
                                      child: const Text("Continue"),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Center(
                              child: ListTile(
                                title: Text(
                                  "Import Wallet",
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
