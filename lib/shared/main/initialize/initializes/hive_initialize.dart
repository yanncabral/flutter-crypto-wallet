import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transfero/shared/main/initialize/initialize.dart';

class HiveInitializer implements Initializer {
  const HiveInitializer();

  @override
  Future<void> call() async {
    final path = await getApplicationDocumentsDirectory();
    Hive.init(path.path);
  }
}
