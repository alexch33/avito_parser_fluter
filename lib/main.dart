import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import 'constants/constants.dart';
import 'controllers/notification_controller.dart';

void callBackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    if (task == BACKGROUND_TASK) {
      await NotificationController().runLongRunningEmailJob();
    }
    return true;
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
      mainUrlController.text = value.getString(PARSING_URL) ?? "";
    });

    super.initState();
  }

  void _runParserInBackground(String url) async {
    await Workmanager.initialize(callBackDispatcher, isInDebugMode: true);

    Workmanager.registerOneOffTask("1", BACKGROUND_TASK);
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
    Workmanager.cancelAll().then((value) {
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
