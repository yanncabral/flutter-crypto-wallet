import 'package:dartz/dartz.dart';
import 'package:transfero/shared/external/hive/hive_shared_preferences.dart';
import 'package:transfero/shared/infra/shared_preferences/shared_preferences_error.dart';
import 'package:meta/meta.dart';

abstract class SharedPreferences {
  static final SharedPreferences _instance = HiveSharedPreferences();
  @protected
  Future<Either<SharedPreferencesError, String>> read({required String key}) {
    return _instance.read(key: key);
  }

  Future<void> write({required String key, required String value}) {
    return _instance.write(key: key, value: value);
  }

  Future<Either<SharedPreferencesError, String>> delete({required String key}) {
    return _instance.delete(key: key);
  }

  factory SharedPreferences() => _instance;
}
