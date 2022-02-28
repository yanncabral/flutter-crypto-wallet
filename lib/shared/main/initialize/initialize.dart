import 'package:transfero/shared/main/initialize/initializes/dot_env_initialize.dart';

abstract class Initializer {
  Future<void> call();
}

mixin ApplicationInitializer {
  static const List<Initializer> _initializers = [
    DotEnvInitializer(),
    // HiveInitializer(),
  ];
  var _wasInitialized = false;

  Future<void> ensureInitialized() async {
    if (!_wasInitialized) {
      await Future.wait(_initializers.map((e) => e()));
      _wasInitialized = true;
    }
  }
}
