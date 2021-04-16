import 'package:avito_parser/utils/notification_helper.dart';

class NotificationController {
  final NotificationHelper notificationHelper = NotificationHelper();
  bool isDone = false;

  runLongRunningEmailJob() async {
    //TODO parsing
    while (!isDone) {
      await Future.delayed(Duration(seconds: 10));
    }
  }

  eventListener(event) async {

  }
}
