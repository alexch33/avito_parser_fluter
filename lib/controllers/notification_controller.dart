import 'dart:math';
import 'package:avito_parser/constants/constants.dart';
import 'package:avito_parser/data/models/ad_model.dart';
import 'package:avito_parser/data/repository/repository.dart';
import 'package:avito_parser/utils/notification_helper.dart';
import 'package:avito_parser/utils/parser/avito_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationController {
  static NotificationController _instance = new NotificationController();
  final NotificationHelper notificationHelper = NotificationHelper();
  final AvitoParser parser = new AvitoParser();
  final Map<String, Ad> urlsAds = {};
  late SharedPreferences sharedPreferences;
  late Repository _repository;
  bool isDone = false;
  String? url;
  final _random = new Random();

  /// Generates a positive random integer uniformly distributed on the range
  /// from [min], inclusive, to [max], exclusive.
  int next(int min, int max) => min + _random.nextInt(max - min);

  runLongRunningEmailJob() async {
    await prepareData();
    await notificationHelper.initialize();
    while (!isDone) {
      List<Ad> adsList = await parser.getAdsListFromMainUrl(url!);
      adsList.forEach((ad) async {
        if (!urlsAds.containsKey(ad.url)) {
          urlsAds.putIfAbsent(ad.url, () => ad);
          int id = await _repository.insertAd(ad);
          ad.id = id;
          await onAdFound(ad);
        }
      });

      await Future.delayed(Duration(seconds: next(10, 20)));
    }
  }

  onAdFound(Ad ad) async {
    notificationHelper.showNotification(ad);
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

  static NotificationController getInstace() {
    return _instance;
  }
}
