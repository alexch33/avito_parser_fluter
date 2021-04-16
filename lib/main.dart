import 'package:flutter/material.dart';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
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
  int _counter = 0;
  final mainUrlController = TextEditingController();
  String userUrl = '';

  @override
  void initState() {
    mainUrlController.text = "TEST";
    super.initState();
  }

  void runParserInBackground(String url) {
    Workmanager.initialize(callBackDispatcher, isInDebugMode: true)
        .then((value) {
      Workmanager.registerOneOffTask("1", BACKGROUND_TASK,
          inputData: {url: url});
    });
  }

  void _runParser() {
    setState(() {
      _counter++;
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
          Expanded(child: Text("")),
          Expanded(
              child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                        onPressed: () {}, child: Text("Start parsing"))),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                    height: 50,
                    width: 200,
                    child: ElevatedButton(
                        onPressed: () {}, child: Text("Stop parsing"))),
              )
            ],
          ))
        ],
      ),
    );
  }
}
