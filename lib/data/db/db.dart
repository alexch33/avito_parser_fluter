import 'package:avito_parser/constants/constants.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class AppDatabase {
  static DatabaseFactory _dbFactory = databaseFactoryIo;
  static AppDatabase _instance;
  Database _db;

  AppDatabase._();

  static Future<AppDatabase> getInstance() async {
    if (_instance == null) {
      _instance = AppDatabase._();
      _instance._db = await _dbFactory.openDatabase(DB_PATH);
    }

    return _instance;
  }

  Database getDb() {
    return _instance?._db;
  }

  dispose() async {
    await _instance._db.close();
    _instance = null;
  }
}
