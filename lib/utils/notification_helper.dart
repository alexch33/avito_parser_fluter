import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class NotificationHelper {
  FlutterLocalNotificationsPlugin _flip;
  NotificationDetails _platformChannelSpecifics;

  Future<void> initialize() async {
    _flip = new FlutterLocalNotificationsPlugin();

    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOs = new IOSInitializationSettings();

    var settings = new InitializationSettings(android: android, iOS: iOs);
    _flip.initialize(settings, onSelectNotification: onSelectNotification);

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
        importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    _platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
  }

  showNotification(ad) {
    _flip.show(ad.id, ad.title, ad.time, _platformChannelSpecifics,
        payload: ad.url);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      if (await canLaunch(payload)) await launch(payload);
    }
  }
}
