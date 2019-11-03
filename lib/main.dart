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
  int level = -1;
  int curSelectItemIdx = -1;
  Map<int, int> curLvWordsMap = new Map();

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

  void _switchCurSelectItemIdx(int idx) {
    setState(() {
      curSelectItemIdx = idx;
    });
  }

  void _switchLevel(lv) {
    setState(() {
      curLvWordsMap.clear();
      LevelData ld = lv == -1 ? null : levelsData[lv];
      if (ld != null) {
        for (int i = 0; i < ld.word.length; ++i) {
          int pos = ld.posx[i] + (8 - ld.posy[i]) * 9;
          curLvWordsMap[pos] = i;
        }
      }
      level = lv;
      curSelectItemIdx = -1;
    });
  }

  // ret: -1.当前item为null 0.normal 1.fixed 2.mask 3.no word
  int _getCurItemType() {
    if (level != -1 && curSelectItemIdx != -1) {
      LevelData ld = levelsData[level];
      bool hasWord = curLvWordsMap.containsKey(curSelectItemIdx);
      if (!hasWord) return 3;
      int idx = curLvWordsMap[curSelectItemIdx];
      bool isMask = ld.mask.indexOf(idx) != -1;
      bool isFixed = ld.answer.indexOf(idx) == -1;
      return isMask ? 2: isFixed ? 1 : 0;
    }
    return -1;
  }

  int _switchCurItemType(int type) {
    if (level != -1 && curSelectItemIdx != -1) {
      LevelData ld = levelsData[level];
      bool hasWord = curLvWordsMap.containsKey(curSelectItemIdx);
      if (!hasWord) return 0;
      int idx = curLvWordsMap[curSelectItemIdx];
      // String word = ld.word[idx];
      setState(() {
        if (type == 0) {
          ld.mask.remove(idx);
          if (ld.answer.indexOf(idx) == -1) {
            ld.answer.add(idx);
            ld.answer.sort();
          }
        } else if (type == 1) {
          ld.mask.remove(idx);
          ld.answer.remove(idx);
        } else if (type == 2) {
          ld.answer.remove(idx);
          if (ld.mask.indexOf(idx) == -1) {
            ld.mask.add(idx);
            ld.mask.sort();
          }
        }
      });
    }
  }

  List<Widget> _getWordsItems() {
    List<Widget> widgets = List();
    LevelData ld = level == -1 ? null : levelsData[level];
    // Map<int, int> wordsMap = new Map();
    // if (ld != null) {
    //   for (int i = 0; i < ld.word.length; ++i) {
    //     int pos = ld.posx[i] + (8 - ld.posy[i]) * 9;
    //     wordsMap[pos] = i;
    //   }
    // }
    for (int i = 0; i < 81; ++i) {
      bool hasWord = curLvWordsMap.containsKey(i);
      bool isSelect = hasWord && i == curSelectItemIdx;
      String imgPath = '';
      String word = '';
      if (hasWord) {
        int idx = curLvWordsMap[i];
        // LevelData ld = levelsData[idx];
        bool isMask = ld.mask.indexOf(idx) != -1;
        bool isFixed = ld.answer.indexOf(idx) == -1;
        imgPath = isMask ? "assets/image/game_tt_bg4.png" :
          isFixed ? "assets/image/game_tt_bg3.png" : "assets/image/game_tt_bg2.png";
        word = ld.word[idx];
      }
      FlatButton button = FlatButton(
        child: Text(
          word,
        ),
        onPressed: () => _switchCurSelectItemIdx(i),
      );
      if (hasWord) {
        widgets.add(
          Container(
            alignment: Alignment.center,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: <Widget>[
                Image.asset(imgPath),
                button,
              ],
            ),
            color: isSelect ? Colors.red : Colors.black38,
          ),
        );
      } else {
        widgets.add(
          Container(
            alignment: Alignment.center,
            child: button,
            color: isSelect ? Colors.red : Colors.black38,
          ),
        );
      }
    }
    return widgets;
  }

  List<Widget> _getFuncsItems() {
    List<Widget> widgets = List();
    widgets.add(
      Padding(padding: EdgeInsets.all(8),),
    );
    widgets.add(
      RaisedButton(
        child: Text('打开'),
        onPressed: () {
          Tools.getFileText(_loadLevelData);
        },
      ),
    );
    widgets.add(
      Padding(padding: EdgeInsets.all(8),),
    );
    widgets.add(
      RaisedButton(
        child: Text('保存'),
        onPressed: () {
        },
      ),
    );
    if (level != -1 && curSelectItemIdx != -1) {
      widgets.add(
        Padding(padding: EdgeInsets.all(8),),
      );
      int type = _getCurItemType();
      widgets.add(
        Flexible(
          child: RadioListTile(
            value:2,
            groupValue: type,
            title: Text('Mask'),
            onChanged:(v) => _switchCurItemType(2),
          ),
        ),
      );
      widgets.add(
        Flexible(
          child: RadioListTile(
            value:1,
            groupValue: type,
            title: Text('Fixed'),
            onChanged:(v) => _switchCurItemType(1),
          ),
        ),
      );
      widgets.add(
        Flexible(
          child: RadioListTile(
            value:0,
            groupValue: type,
            title: Text('Normal'),
            onChanged:(v) => _switchCurItemType(0),
          ),
        ),
      );
      widgets.add(
        Padding(padding: EdgeInsets.all(8),),
      );
    }
    return widgets;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(level == -1 ? widget.title : "第$level关"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(padding: EdgeInsets.all(4),),
            Row(
              children: _getFuncsItems(),
            ),
            Padding(padding: EdgeInsets.all(4),),
            Expanded(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 200,
                    child: ListView.builder(
                      itemCount: levelsData.length,
                      itemBuilder: (BuildContext context, int idx) {
                        return Center(
                          // child: Text("第$idx关")
                          // child: FlatButton(
                          //   child: Text("第$idx关"),
                          //   onPressed: () => _switchLevel(idx),
                          // ),
                          child: RadioListTile(
                            value: idx,
                            groupValue: level,
                            activeColor: Colors.red,
                            onChanged: (t) => _switchLevel(idx),
                            title: Text(
                              "第$idx关",
                              style: TextStyle(
                                color: idx == level ? Colors.red : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                      padding: EdgeInsets.all(4),
                    ),
                  ),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 9,
                      crossAxisSpacing: 20.0,
                      mainAxisSpacing: 20.0,
                      padding: EdgeInsets.all(10.0),
                      children: _getWordsItems(),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
