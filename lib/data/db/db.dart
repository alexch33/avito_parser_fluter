import 'package:avito_parser/constants/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class AppDatabase {
  static DatabaseFactory _dbFactory = databaseFactoryIo;
  static AppDatabase _instance;
  Database _db;

  AppDatabase._();

  static Future<AppDatabase> getInstance() async {
    if (_instance == null) {
      final appDocumentDir = await getApplicationDocumentsDirectory();

      // Path with the form: /platform-specific-directory/demo.db
      final dbPath = join(appDocumentDir.path, DB_PATH);
      _instance = AppDatabase._();
      _instance._db = await _dbFactory.openDatabase(dbPath);
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
