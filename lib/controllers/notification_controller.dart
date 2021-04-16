import 'package:avito_parser/constants/constants.dart';
import 'package:avito_parser/data/models/ad_model.dart';
import 'package:avito_parser/data/repository/repository.dart';
import 'package:avito_parser/utils/notification_helper.dart';
import 'package:avito_parser/utils/parser/avito_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController {
  final NotificationHelper notificationHelper = NotificationHelper();
  final AvitoParser parser = new AvitoParser();
  final Map<String, Ad> urlsAds = {};
  SharedPreferences sharedPreferences;
  Repository _repository;
  bool isDone = false;
  String url;

  runLongRunningEmailJob() async {
    await prepareData();
    
    while (!isDone) {
      print("Parsing url: $url");
      List<Ad> adsList = await parser.getAdsListFromMainUrl(url);
      adsList.forEach((ad) {
        if (!urlsAds.containsKey(ad.url)) {
          onAdFound(ad);
          urlsAds.putIfAbsent(ad.url, () => ad);
          _repository.insertAd(ad);
        }
      });
      await Future.delayed(Duration(seconds: 10));
    }
  }

  onAdFound(Ad ad) async {
    notificationHelper.showNotification(ad.title, ad.url);
  }

  Future<void> prepareData() async {
    _repository = Repository();
    await _repository.initialize();
    List<Ad> dbAds = await _repository.getAdsList();
    dbAds.forEach((ad) {
      urlsAds.putIfAbsent(ad.url, () => ad);
    });

    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.reload();

    url = sharedPreferences.getString(PARSING_URL);
  }
}
