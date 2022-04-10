import 'package:avito_parser/data/db/db.dart';
import 'package:avito_parser/data/models/ad_model.dart';
import 'package:avito_parser/data/sources/ad_source.dart';

class Repository {
  late AdDataSource _adDataSource;
  bool isInited = false;

  Future<void> initialize() async {
    if (!isInited) {
      AppDatabase dataBase = await AppDatabase.getInstance();
      _adDataSource = AdDataSource(dataBase.getDb()!);
      isInited = true;
    }
  }

  Future<List<Ad>> getAdsList() async {
    return _adDataSource.getAdsFromDb();
  }

  Future<int> insertAd(Ad ad) async {
    return _adDataSource.insert(ad);
  }
}
