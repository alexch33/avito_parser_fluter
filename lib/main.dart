import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workmanager/workmanager.dart';
import 'package:rxdart/subjects.dart';

import 'constants/constants.dart';
import 'controllers/notification_controller.dart';

void callBackDispatcher() async {
  while (true) {
    try {
      Workmanager().executeTask((task, inputData) async {
        if (task == BACKGROUND_TASK) {
          try {
            await NotificationController.getInstace().runLongRunningEmailJob();
          } catch (err) {}
        }
        return Future.value(true);
      });
    } catch (err) {}
    // print(DateTime.now().toString() + " running " + isRunning.toString());
    await Future.delayed(Duration(seconds: 3));
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

final BehaviorSubject<ReceivedNotification> didReceiveLocalNotificationSubject =
    BehaviorSubject<ReceivedNotification>();

final BehaviorSubject<String> selectNotificationSubject =
    BehaviorSubject<String>();

class ReceivedNotification {
  ReceivedNotification({
    this.id,
    this.title,
    this.body,
    this.payload,
  });

  final int id;
  final String title;
  final String body;
  final String payload;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  String selectedNotificationPayload;
  final NotificationAppLaunchDetails notificationAppLaunchDetails =
      await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  // String initialRoute = HomePage.routeName;
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails?.payload;
    // initialRoute = SecondPage.routeName;
    if (selectedNotificationPayload != null) {
      if (await canLaunch(selectedNotificationPayload))
        await launch(selectedNotificationPayload);
    }
  }

  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS =
      IOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
          onDidReceiveLocalNotification:
              (int id, String title, String body, String payload) async {
            didReceiveLocalNotificationSubject.add(ReceivedNotification(
                id: id, title: title, body: body, payload: payload));
          });
  const MacOSInitializationSettings initializationSettingsMacOS =
      MacOSInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false);
  final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onSelectNotification: (String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
      if (selectedNotificationPayload != null) {
        if (await canLaunch(selectedNotificationPayload))
          await launch(selectedNotificationPayload);
      }
    }
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  });

  runApp(MyApp(selectedNotificationPayload));
}

class MyApp extends StatelessWidget {
  final String selectedNotificationPayload;

  MyApp(this.selectedNotificationPayload);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Avito Parser',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Avito Parser'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _curentStatus = PARSER_STATUS_WAITING_INFO;
  final mainUrlController = TextEditingController();

  @override
  void initState() {
    SharedPreferences.getInstance().then((value) {
      _curentStatus = value.getString(PARSER_STATUS) ?? PARSER_STATUS_STOPPED;
      mainUrlController.text = value.getString(PARSING_URL) ??
          "https://www.avito.ru/rostovskaya_oblast/noutbuki?s=101&user=1";
    });

    super.initState();
  }

  void _runParserInBackground(String url) async {
    await Workmanager().initialize(callBackDispatcher, isInDebugMode: false);

    Workmanager().registerOneOffTask("1", BACKGROUND_TASK);
  }

  void _runParser() {
    if (mainUrlController.text.isEmpty) return;

    SharedPreferences.getInstance().then((value) async {
      await value.reload();
      value.setString(PARSING_URL, mainUrlController.text.trim());
      value.setString(PARSER_STATUS, PARSER_STATUS_RUNNING);
      _runParserInBackground(mainUrlController.text);
      setState(() {
        _curentStatus = PARSER_STATUS_RUNNING;
      });
    });
  }

  void _stopParser() {
    Workmanager().cancelAll().then((value) {
      SharedPreferences.getInstance().then((value) async {
        value.reload();
        value.setString(PARSER_STATUS, PARSER_STATUS_STOPPED);
      });
      setState(() {
        _curentStatus = PARSER_STATUS_STOPPED;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
              child: Padding(
            padding: EdgeInsets.only(top: 16),
            child: TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Avito Url',
                ),
                controller: mainUrlController),
          )),
          Expanded(child: Text(_curentStatus)),
          Expanded(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                        onPressed: _runParser, child: Text("Start parsing"))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                        onPressed: _stopParser, child: Text("Stop parsing"))),
              )
            ],
          ))
        ],
      ),
    );
  }
}
