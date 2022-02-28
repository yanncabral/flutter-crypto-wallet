import 'package:flutter/foundation.dart';
import 'package:http/http.dart';
import 'package:transfero/shared/data/service/contract_service.dart';
import 'package:transfero/shared/domain/entities/network_type.dart';
import 'package:transfero/shared/infra/network_types_settings/network_types_settings.dart';
import 'package:transfero/shared/utils/contract_parser/contract_parser.dart';
import 'package:web3dart/web3dart.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ContractLocator {
  ContractLocator._();

  static Map<NetworkType, ContractService> instance =
      <NetworkType, ContractService>{};

  ContractService getInstance(NetworkType network) {
    return instance[network]!;
  }

  static Future<ContractService> createInstance(
      NetworkTypeSettings networkConfig) async {
    final wsAddress = networkConfig.web3RdpUrl;
    final client = Web3Client(networkConfig.web3HttpUrl, Client(),
        socketConnector: wsAddress != null
            ? () {
                final channel = kIsWeb
                    ? WebSocketChannel.connect(Uri.parse(wsAddress))
                    : IOWebSocketChannel.connect(wsAddress);

                return channel.cast<String>();
              }
            : null);

    final contract = await ContractParser.fromAssets(
        'TargaryenCoin.json', networkConfig.contractAddress);

    return ContractService(client, contract);
  }
}
