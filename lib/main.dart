import 'dart:convert';
import 'dart:io';
import 'dart:core';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
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

class SelectableInfo {
  String idiom;
  int index;
  bool isHor;
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
  List<LocalLevelData> levelsData = new List();
  List<SelectableInfo> selectableInfos = new List();
  Set<String> idiomsSet = new Set();
  int level = -1;
  int curSelectItemIdx = -1;
  // Map<int, int> curLvWordsMap = new Map();

  LocalLevelData _getCurLvData() {
    if (level < 0 || level > levelsData.length) return null;
    return levelsData[level];
  }

  void _loadIdioms(BuildContext context) {
    if (idiomsSet.length > 0) return;
      // AssetBundle.loadString('assets/idioms.json');
    DefaultAssetBundle.of(context).loadString('assets/config/idioms.json').then((onValue) {
      // debugPrint(onValue);
      setState(() {
        // idiomsSet.clear();
        List<dynamic> idioms = jsonDecode(onValue);
        for (String idiom in idioms) {
          idiomsSet.add(idiom);
        }
      });
    });
  }

  void _loadLevelData(String txt) {
    setState(() {
      levelsData.clear();
      // idiomsSet.clear();
      dynamic json = new JsonDecoder().convert(txt);
      for (dynamic data in json) {
        LevelData ld = new LevelData.fromJson(data);
        LocalLevelData lld = LocalLevelData.fromLevelData(ld);
        levelsData.add(lld);
      }
    });
  }

  void _switchCurSelectItemIdx(int idx) {
    setState(() {
      curSelectItemIdx = idx;
      _buildSelectableInfos();
    });
  }

  void _switchLevel(lv) {
    setState(() {
      level = lv;
      curSelectItemIdx = -1;
      _buildSelectableInfos();
    });
  }

  // ret: -1.当前item为null 0.normal 1.fixed 2.mask 3.no word
  int _getCurItemType() {
    if (level != -1 && curSelectItemIdx != -1) {
      LocalLevelData lld = _getCurLvData();
      return lld.types[curSelectItemIdx];
    }
    return -1;
  }

  void _switchCurItemType(int type) {
    if (level != -1 && curSelectItemIdx != -1) {
      setState(() {
        LocalLevelData lld = _getCurLvData();
        lld.types[curSelectItemIdx] = type;
      });
    }
  }

  void _buildSelectableInfos() {
    setState(() {
      selectableInfos.clear();
      LocalLevelData ld = _getCurLvData();
      int idx = curSelectItemIdx;
      if (ld != null && idx != -1) {
        List<int> idxsHor = ld.getPushIdiomIdxs(idx, true);
        List<int> idxsVer = ld.getPushIdiomIdxs(idx, false);
        Function fun = (List<int> idxs, bool isHor) {
          if (idxs != null && idxs.length > 0) {
            String word = ld.words[idx];
            if (word.length > 0) {
              for (String idiom in idiomsSet) {
                int idx = idiom.indexOf(word);
                if (idx != -1 && idxs.indexOf(idx) != -1) {
                  // idioms.add(idiom);
                  SelectableInfo si = SelectableInfo();
                  si.idiom = idiom;
                  si.index = idx;
                  si.isHor = isHor;
                  selectableInfos.add(si);
                }
              }
            }
          }
        };
        fun(idxsHor, true);
        fun(idxsVer, false);
      }
    });
  }

  void _addIdiom(SelectableInfo info) {
    setState(() {
      LocalLevelData ld = _getCurLvData();
      if (ld != null) {
        int idx = curSelectItemIdx - info.index * (info.isHor ? 1 : 9);
        for (int i = 0; i < 4; ++i) {
          if (idx != curSelectItemIdx) {
            ld.addWord(idx, info.idiom[i]);
          } 
          if (info.isHor) idx++; else idx += 9;
        }
      }
      _buildSelectableInfos();
    });
  }

  Widget _getCurIdiomList() {
    // List<String> idioms = new List();
    List<SelectableInfo> infos = selectableInfos;
    return ListView.builder(
      itemCount: infos.length,
      itemBuilder: (BuildContext context, int idx) {
        SelectableInfo info = infos[idx];
        String idiom = info.idiom;
        return Center(
          child: RichText(
            text: TextSpan(
              text: idiom.substring(0, info.index).toString(),
              style: TextStyle(color: Colors.black),
              children: [
                TextSpan(
                  text: idiom.substring(info.index, info.index + 1).toString(),
                  style: TextStyle(color: Colors.red),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _addIdiom(info);
                    },
                ),
                TextSpan(
                  text: idiom.substring(info.index + 1, idiom.length).toString(),
                  style: TextStyle(color: Colors.black),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _addIdiom(info);
                    },
                ),
              ],
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  _addIdiom(info);
                },
            ),
          ),
          // child: FlatButton(
          //   child: Text(info.idiom),
          //   onPressed: () {
          //     _addIdiom(info);
          //   },
          // ),
        );
      },
      padding: EdgeInsets.all(4),
    );
  }

  List<Widget> _getWordsItems() {
    List<Widget> widgets = List();
    LocalLevelData lld = _getCurLvData();
    for (int i = 0; i < 81; ++i) {
      // bool hasWord = curLvWordsMap.containsKey(i);
      bool hasWord = false;
      bool isSelect = false;
      String word = '';
      String imgPath = '';
      if (lld != null) {
        word = lld.words[i];
        hasWord = word.length > 0;
        isSelect = i == curSelectItemIdx;
        if (hasWord) {
          int type = lld.types[i];
          bool isMask = type == 2;
          bool isFixed = type == 1;
          imgPath = isMask ? "assets/image/game_tt_bg4.png" :
            isFixed ? "assets/image/game_tt_bg3.png" : "assets/image/game_tt_bg2.png";
          // word = ld.word[idx];
        }
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
        child: Text('Open'),
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
        child: Text('Save'),
        onPressed: () {
          StringBuffer buffer = new StringBuffer('[');
          int len = levelsData.length;
          for (int i = 0; i < len; ++i) {
            LocalLevelData data = levelsData[i];
            LevelData ld = data.toLevelData();
            final string = jsonEncode(ld.toJson());
            buffer.write(string);
            if (i < len - 1) buffer.write(',');
            buffer.write('\n');
          }
          buffer.write(']');
          Tools.saveFile(buffer.toString());
        },
      ),
    );
    if (level != -1 && curSelectItemIdx != -1) {
      LocalLevelData lld = _getCurLvData();
      widgets.add(
        Padding(padding: EdgeInsets.all(8),),
      );
      int type = _getCurItemType();
      if (lld.hasWord(curSelectItemIdx)) {
      // 选择当前文字状态
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
        // 删除文字
        widgets.add(
          RaisedButton(
            child: Text('RM Word'),
            onPressed: () {
              if (level != -1 && curSelectItemIdx != -1) {
                setState(() {
                  LocalLevelData lld = _getCurLvData();
                  if (lld != null) {
                    lld.rmWord(curSelectItemIdx);
                    _buildSelectableInfos();
                  }
                });
              }
            },
          ),
        );
        widgets.add(
          Padding(padding: EdgeInsets.all(8),),
        );
      }
      // 修改文字
      String word = lld.words[curSelectItemIdx];
      widgets.add(
        Flexible(
          child: TextField(
            controller: new TextEditingController(text: word),
            onChanged: (String txt) {
              lld.setWord(curSelectItemIdx, txt);
              _buildSelectableInfos();
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: '修改文字',
            ),
            // maxLength: 1,
          )
        ),
      );
      widgets.add(
        Padding(padding: EdgeInsets.all(8),),
      );

      // 删除水平方向成语
      if (lld.isRemoveable(curSelectItemIdx, true)) {
        widgets.add(
          RaisedButton(
            child: Text('RM Hor'),
            onPressed: () {
              if (level != -1 && curSelectItemIdx != -1) {
                setState(() {
                  LocalLevelData lld = _getCurLvData();
                  if (lld != null) {
                    // lld.rmWord(curSelectItemIdx);
                    lld.rmIdiom(curSelectItemIdx, true);
                    _buildSelectableInfos();
                  }
                });
              }
            },
          ),
        );
        
        widgets.add(
          Padding(padding: EdgeInsets.all(8),),
        );
      }

      // 删除竖直方向成语
      if (lld.isRemoveable(curSelectItemIdx, false)) {
        widgets.add(
          RaisedButton(
            child: Text('RM Ver'),
            onPressed: () {
              if (level != -1 && curSelectItemIdx != -1) {
                setState(() {
                  LocalLevelData lld = _getCurLvData();
                  if (lld != null) {
                    // lld.rmWord(curSelectItemIdx);
                    lld.rmIdiom(curSelectItemIdx, false);
                    _buildSelectableInfos();
                  }
                });
              }
            },
          ),
        );
        widgets.add(
          Padding(padding: EdgeInsets.all(8),),
        );
      }
      
      // 删除所有文字
      widgets.add(
        RaisedButton(
          child: Text('RM ALL'),
          onPressed: () {
            setState(() {
                LocalLevelData lld = _getCurLvData();
                if (lld != null) {
                  lld.rmAllWord();
                  _buildSelectableInfos();
                }
              });
          },
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
    _loadIdioms(context);
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
                    // 关卡列表
                    child: ListView.builder(
                      itemCount: levelsData.length,
                      itemBuilder: (BuildContext context, int idx) {
                        return Center(
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
                  ),
                  Container(
                    width: 200,
                    // 当前可选成语列表
                    child: _getCurIdiomList(),
                  ),
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
