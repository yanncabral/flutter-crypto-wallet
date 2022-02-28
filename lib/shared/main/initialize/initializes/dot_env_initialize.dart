import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:transfero/shared/main/initialize/initialize.dart';

class DotEnvInitializer implements Initializer {
  const DotEnvInitializer();

  @override
  Future<void> call() async {
    await dotenv.load(fileName: ".env");
  }
}
