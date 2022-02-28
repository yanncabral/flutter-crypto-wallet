import 'package:flutter/widgets.dart';

class CryptoCoin {
  final ImageProvider image;
  final String name;
  final String code;
  final double price;

  CryptoCoin({
    required this.image,
    required this.name,
    required this.code,
    required this.price,
  });
}

class Coin {
  final String imageUrl;
  final String name;
  final String code;
  final num price;

  Coin({
    required this.imageUrl,
    required this.name,
    required this.code,
    required this.price,
  });
}
