import 'package:avito_parser/data/db/db.dart';
import 'package:avito_parser/data/models/ad_model.dart';
import 'package:avito_parser/data/sources/ad_source.dart';

class Repository {
  AdDataSource _adDataSource;

  Repository() {
    AppDatabase.getInstance().then((dataBase) {
      _adDataSource = AdDataSource(dataBase.getDb());
    });
  }

  Future<List<Ad>> getAdsList() async {
    return _adDataSource.getAdsFromDb();
  }

  Future<int> insertAd(Ad ad) async {
    return _adDataSource.insert(ad);
  }
}