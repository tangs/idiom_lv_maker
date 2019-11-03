import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'tools.dart';
import 'idiom_data.dart';

// Sets a platform override for desktop to avoid exceptions. See
// https://flutter.dev/desktop#target-platform-override for more info.
void _enablePlatformOverrideForDesktop() {
  if (!kIsWeb && (Platform.isMacOS || Platform.isWindows || Platform.isLinux)) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

void main() {
  _enablePlatformOverrideForDesktop();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Idiom Level Maker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Idiom Level Maker'),
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
  // int _counter = 0;
  List<LevelData> levelsData = new List();

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      // _counter++;
    });
  }

  void _loadLevelData(String txt) {
    setState(() {
      levelsData.clear();
      dynamic json = new JsonDecoder().convert(txt);
      for (dynamic data in json) {
        LevelData ld = new LevelData.fromJson(data);
        levelsData.add(ld);
      }
    });
  }

  void _switchLevel(lv) {

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.all(4),),
            Row(
              children: <Widget>[
                Padding(padding: EdgeInsets.all(8),),
                RaisedButton(
                  child: Text('打开'),
                  onPressed: () {
                    Tools.getFileText(_loadLevelData);
                  },
                ),
                Padding(padding: EdgeInsets.all(8),),
                RaisedButton(
                  child: Text('保存'),
                  onPressed: () => {
                    
                  },
                ),
              ],
            ),
            Padding(padding: EdgeInsets.all(4),),
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 100,
                    child: ListView.builder(
                      itemCount: levelsData.length,
                      itemBuilder: (BuildContext context, int idx) {
                        return Center(
                          // child: Text("第$idx关")
                          child: FlatButton(
                            child: Text("第$idx关"),
                            onPressed: () => _switchLevel(idx),
                          ),
                        );
                      },
                      padding: EdgeInsets.all(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
