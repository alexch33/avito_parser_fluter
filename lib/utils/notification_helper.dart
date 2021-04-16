import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationHelper {
  FlutterLocalNotificationsPlugin _flip;
  NotificationDetails _platformChannelSpecifics;

  NotificationHelper() {
    _flip = new FlutterLocalNotificationsPlugin();

    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOs = new IOSInitializationSettings();

    var settings = new InitializationSettings(android: android, iOS: iOs);
    _flip.initialize(settings);

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'channel_id', 'channel_name', 'channel_description',
        importance: Importance.max, priority: Priority.high);
    var iOSPlatformChannelSpecifics = new IOSNotificationDetails();

    _platformChannelSpecifics = new NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics);
  }

  showNotification(String title, String text) {
    _flip.show(0, title, text, _platformChannelSpecifics);
  }
}
