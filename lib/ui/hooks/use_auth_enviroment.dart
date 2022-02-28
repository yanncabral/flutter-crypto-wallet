import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:transfero/shared/domain/enviroment/auth_enviroment.dart';

AuthEnviroment useAuthEnviroment() {
  return useMemoized(() => AuthEnviroment());
}
