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

enum SelectableType {
  Add,
  Replace,
}

class SelectableInfo {
  SelectableType type;
  String idiom;
  String selectableTxt;
  int firstWordIdx;
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
  String idiomKeyword = '';
  String searchLv = '';
  bool showAppendIdiom = true;
  bool showReplaceIdiom = true;
  bool showHorIdiom = true;
  bool showVerIdiom = true;

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

  void _loadLevelData(int error, String txt) {
    if (error != 0) return;
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

  void _setIdiomKeyword(String keyword) {
    setState(() {
      idiomKeyword = keyword == null ? '' : keyword;
      _buildSelectableInfos();
    });
  }

  void _switchCurSelectItemIdx(int idx) {
    setState(() {
      curSelectItemIdx = idx;
      _setIdiomKeyword('');
      _buildSelectableInfos();
    });
  }

  void _switchLevel(lv) {
    setState(() {
      level = lv;
      _buildSelectableInfos();
      _switchCurSelectItemIdx(-1);
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
        bool hasWordCurLv = ld.hasWordCurLv();
        String word = ld.words[idx];
        bool canAppend = !hasWordCurLv || word.length > 0;

        Function check = (String idiom, String info) {
          if (idiom.length != 4 || info.length != 4) return false;
          for (int i = 0; i < 4; ++i) {
            if (info[i] != '.' && info[i] != idiom[i]) return false;
          }
          return true;
        };

        Function appendIdiom = (List<int> idxs, bool isHor) {
          if (canAppend && idxs.length > 0) {
            for (String idiom in idiomsSet) {
              int start = 0;
              do {
                int idx = idiom.indexOf(word, start);
                if (!hasWordCurLv) {
                  idx = start;
                }
                if (idx != -1 && idxs.indexOf(idx) != -1) {
                  String selectableTxt = '';
                  for (int i = 0; i < idiom.length; ++i) {
                    selectableTxt += i != idx ? '.' : idiom[i];
                  }
                  SelectableInfo si = SelectableInfo();
                  si.type = SelectableType.Add;
                  si.idiom = idiom;
                  si.firstWordIdx = curSelectItemIdx - idx * (isHor ? 1 : 9);
                  si.selectableTxt = selectableTxt;
                  si.isHor = isHor;
                  if (idiomKeyword.length == 0 || idiom.indexOf(idiomKeyword) != -1) {
                    selectableInfos.add(si);
                  }
                  start = idx + 1;
                } else {
                  break;
                }
              } while (true);
            }
          }
        };
        Function fun = (int idx, bool isHor) {
          String info = ld.getSelecetableInfo(idx, isHor);
          List<int> idxs = ld.getPushIdiomIdxs(idx, isHor);
          List<int> idiomIdxs = ld.getIdiomIdx(idx, isHor);
          // bool hasIdiom = ld.hasIdiom(idx, isHor);
          if (idiomIdxs.length != 4) {
            if (showAppendIdiom) {
              appendIdiom(idxs, isHor);
            }
          } else if (info.length == 4) {
            if (showReplaceIdiom) {
              String curIdiom = ld.getIdiom(idx, isHor);
              // contains idiom
              for (String idiom in idiomsSet) {
                if (check(idiom, info) && idiom != curIdiom) {
                  SelectableInfo si = SelectableInfo();
                  si.type = SelectableType.Replace;
                  si.idiom = idiom;
                  si.firstWordIdx = idiomIdxs[0];
                  si.selectableTxt = info;
                  si.isHor = isHor;
                  selectableInfos.add(si);
                }
              }
            }
          }
        };
        if (showHorIdiom) fun(idx, true);
        if (showVerIdiom) fun(idx, false);
      }
    });
  }

  void _addIdiom(SelectableInfo info) {
    setState(() {
      LocalLevelData ld = _getCurLvData();
      if (ld != null) {
        // bool hasWordCurLv = ld.hasWordCurLv();
        int idx = info.firstWordIdx;
        for (int i = 0; i < 4; ++i) {
          ld.setWord(idx, info.idiom[i]);
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
              text: idiom[0].toString(),
              style: TextStyle(color: (info.selectableTxt[0] != '.' ? Colors.red : Colors.black)),
              children: [
                TextSpan(
                  text: idiom[1].toString(),
                  style: TextStyle(color: (info.selectableTxt[1] != '.' ? Colors.red : Colors.black)),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _addIdiom(info);
                    },
                ),
                TextSpan(
                  text: idiom[2].toString(),
                  style: TextStyle(color: (info.selectableTxt[2] != '.' ? Colors.red : Colors.black)),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _addIdiom(info);
                    },
                ),
                TextSpan(
                  text: idiom[3].toString(),
                  style: TextStyle(color: (info.selectableTxt[3] != '.' ? Colors.red : Colors.black)),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _addIdiom(info);
                    },
                ),
                TextSpan(
                  text: '[' + (info.isHor ? '水平' : '竖直') + ']',
                  style: TextStyle(color: Colors.black),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      _addIdiom(info);
                    },
                ),
                TextSpan(
                  text: '[' + (info.type == SelectableType.Add ? '新增' : '替换') + ']',
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
        padding: EdgeInsets.all(0),
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
        child: Text('下载'),
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
              title: Text('隐藏'),
              onChanged:(v) => _switchCurItemType(2),
            ),
          ),
        );
        widgets.add(
          Flexible(
            child: RadioListTile(
              value:1,
              groupValue: type,
              title: Text('固定'),
              onChanged:(v) => _switchCurItemType(1),
            ),
          ),
        );
        widgets.add(
          Flexible(
            child: RadioListTile(
              value:0,
              groupValue: type,
              title: Text('普通'),
              onChanged:(v) => _switchCurItemType(0),
            ),
          ),
        );
        widgets.add(
          Padding(padding: EdgeInsets.all(8),),
        );
      }
    }
    return widgets;
  }

  List<Widget> _getFuncsItems1() {
    List<Widget> widgets = List();
    widgets.add(
      Padding(padding: EdgeInsets.all(8),),
    );
    if (level != -1 && curSelectItemIdx != -1) {
      LocalLevelData lld = _getCurLvData();
      if (lld.hasWord(curSelectItemIdx)) {
      // 选择当前文字状态
        // 删除文字
        widgets.add(
          RaisedButton(
            child: Text('删字'),
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
            onSubmitted: (String txt) {
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
            child: Text('删成语(H)'),
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
            child: Text('删成语(V)'),
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
          child: Text('清空'),
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
  
  Widget _getLvCell(int idx) {
    return RadioListTile(
      // isThreeLine: true,
      value: idx,
      groupValue: level,
      activeColor: Colors.red,
      onChanged: (t) => _switchLevel(idx),
      title: Text(
        'LV $idx',
        style: TextStyle(
          color: idx == level ? Colors.red : Colors.black,
        ),
      ),
      // subtitle: FlatButton(
      //   padding: EdgeInsets.all(0),
      //   child: Text('插入'),
      //   onPressed: () => {

      //   },
      // ),
      // title: FlatButton(
      //   padding: EdgeInsets.all(0),
      //   child: Text('删除'),
      //   onPressed: () => {

      //   },
      // ),
    );
  }

  Widget _getLvsItem() {
    if (searchLv.length > 0) {
      int lv = int.parse(searchLv);
      if (lv >= 0 && lv <= levelsData.length) {
        return _getLvCell(lv);
      } else {
        return Center();
      }
    }
    return Scrollbar(
      child: ListView.builder(
        itemCount: levelsData.length,
        itemBuilder: (BuildContext context, int idx) {
          return Center(
            child: _getLvCell(idx),
          );
        },
        padding: EdgeInsets.all(4),
      ),
    );
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
            Row(
              children: _getFuncsItems1(),
            ),
            Padding(padding: EdgeInsets.all(4),),
            Expanded(
              child: Row(
                children: <Widget>[
                  Padding(padding: EdgeInsets.all(8),),
                  Container(
                    width: 160,
                    child: Column(
                      children: <Widget>[
                        TextField(
                          keyboardType: TextInputType.number,
                          controller: new TextEditingController(text: searchLv),
                          onSubmitted: (String txt) {
                            setState(() {
                              searchLv = txt;
                            });
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '搜索关卡',
                          ),
                        ),
                        // 关卡列表
                        Expanded(
                          child: _getLvsItem(),
                        )
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8),),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 9,
                      crossAxisSpacing: 20.0,
                      mainAxisSpacing: 20.0,
                      padding: EdgeInsets.all(4.0),
                      children: _getWordsItems(),
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8),),
                  Container(
                    width: 200,
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: new TextEditingController(text: idiomKeyword),
                          onSubmitted: (String txt) {
                            _setIdiomKeyword(txt);
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: '搜索成语',
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: showHorIdiom,
                              onChanged: (bool val) {
                                setState(() {
                                  showHorIdiom = val;
                                  _buildSelectableInfos();
                                });
                              },
                            ),
                            Text('水平'),
                            Padding(padding: EdgeInsets.all(8),),
                            Checkbox(
                              value: showVerIdiom,
                              onChanged: (bool val) {
                                setState(() {
                                  showVerIdiom = val;
                                  _buildSelectableInfos();
                                });
                              },
                            ),
                            Text('竖直'),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Checkbox(
                              value: showAppendIdiom,
                              onChanged: (bool val) {
                                setState(() {
                                  showAppendIdiom = val;
                                  _buildSelectableInfos();
                                });
                              },
                            ),
                            Text('新增'),
                            Padding(padding: EdgeInsets.all(8),),
                            Checkbox(
                              value: showReplaceIdiom,
                              onChanged: (bool val) {
                                setState(() {
                                  showReplaceIdiom = val;
                                  _buildSelectableInfos();
                                });
                              },
                            ),
                            Text('替换'),
                          ],
                        ),
                        Expanded(
                          child: _getCurIdiomList(),
                        )
                      ],
                    ),
                  ),
                  Padding(padding: EdgeInsets.all(8),),
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
