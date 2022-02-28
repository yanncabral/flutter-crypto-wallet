import 'package:dartz/dartz.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:transfero/shared/infra/shared_preferences/shared_preferences.dart';
import 'package:transfero/shared/infra/shared_preferences/shared_preferences_error.dart';
import 'package:transfero/shared/main/initialize/initialize.dart';

Future<Box> _getBox() async {
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);
  final box = await Hive.openBox(
    "shared_preferences_2",
    // encryptionCipher: HiveAesCipher(Hive.generateSecureKey()),
  );
  return box;
}

class HiveSharedPreferences
    with ApplicationInitializer
    implements SharedPreferences {
  HiveSharedPreferences();
  static final _box = _getBox();

  @override
  Future<Either<SharedPreferencesError, String>> read(
      {required String key}) async {
    ensureInitialized();
    final value = (await _box).get(key);
    if (value == null) {
      return const Left(SharedPreferencesError.notFound);
    } else if (value is String) {
      return Right(value);
    } else {
      return const Left(SharedPreferencesError.unexpected);
    }
  }

  @override
  Future<void> write({required String key, required String value}) async {
    ensureInitialized();
    final box = await _box;
    return box.put(key, value).then((value) => box.flush());
  }

  @override
  Future<Either<SharedPreferencesError, String>> delete(
      {required String key}) async {
    ensureInitialized();
    _box.then((value) => value.delete(key));
    return const Right("");
  }
}
