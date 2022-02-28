import 'package:transfero/shared/domain/entities/network_type.dart';

class NetworkTypeSettings {
  NetworkTypeSettings(
    this.web3HttpUrl,
    this.contractAddress, {
    required this.symbol,
    required this.faucetUrl,
    required this.enabled,
    required this.label,
    this.web3RdpUrl,
  });
  final String? web3RdpUrl;
  final String web3HttpUrl;
  final String contractAddress;
  final String symbol;
  final String faucetUrl;

  final bool enabled;
  final String label;
}

extension NetworkTypesSettings on NetworkType {
  NetworkTypeSettings get settings {
    switch (this) {
      case NetworkType.local:
        return NetworkTypeSettings(
          'http://192.168.40.197:8545',
          '0xD933a953f4786Eed5E58D234dFeadE15c96bAa8b',
          web3RdpUrl: 'ws://192.168.40.197:8545',
          symbol: 'ETH',
          faucetUrl: 'about:blank',
          enabled: false,
          label: 'Local (Truffle)',
        );
      case NetworkType.etherium:
        return NetworkTypeSettings(
          'https://ropsten.infura.io/v3/628074215a2449eb960b4fe9e95feb09',
          '0x5060b60cb8Bd1C94B7ADEF4134555CDa7B45c461',
          web3RdpUrl:
              'wss://ropsten.infura.io/ws/v3/628074215a2449eb960b4fe9e95feb09',
          symbol: 'ETH',
          faucetUrl: 'https://faucet.ropsten.be',
          enabled: true,
          label: 'Ethereum (Ropsten)',
        );
      case NetworkType.matic:
        return NetworkTypeSettings(
          'https://rpc-mumbai.maticvigil.com',
          '0x73434bb95eC80d623359f6f9d7b84568407187BA',
          web3RdpUrl: 'wss://ws-mumbai.matic.today',
          symbol: 'MATIC',
          faucetUrl: 'https://faucet.matic.network',
          enabled: true,
          label: 'Matic (Mumbai)',
        );
      case NetworkType.bsc:
        return NetworkTypeSettings(
          'https://data-seed-prebsc-1-s1.binance.org:8545',
          '0x73434bb95eC80d623359f6f9d7b84568407187BA',
          symbol: 'BNB',
          faucetUrl: 'https://testnet.binance.org/faucet-smart',
          enabled: true,
          label: 'Binance Chain (BSC)',
        );
    }
  }
}
