class LevelData {
  int id;
  List<int> posx;
  List<int> posy;
  List<int> answer;
  int levelup;
  int hero;
  List<String> idiom;
  int wifenum;
  int house;
  List<String> word;
  List<int> mask;

  LevelData({
    this.id,
    this.posx,
    this.posy,
    this.answer,
    this.levelup,
    this.hero,
    this.idiom,
    this.wifenum,
    this.house,
    this.word,
    this.mask,
  });
  LevelData.fromJson(Map<String, dynamic> json) {
    id = json["id"]?.toInt();
    if (json["posx"] != null) {
      var v = json["posx"];
      var arr0 = List<int>();
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      posx = arr0;
    }
    if (json["posy"] != null) {
      var v = json["posy"];
      var arr0 = List<int>();
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      posy = arr0;
    }
    if (json["answer"] != null) {
      var v = json["answer"];
      var arr0 = List<int>();
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      answer = arr0;
    }
    levelup = json["levelup"]?.toInt();
    hero = json["hero"]?.toInt();
    if (json["idiom"] != null) {
      var v = json["idiom"];
      var arr0 = List<String>();
      v.forEach((v) {
        arr0.add(v.toString());
      });
      idiom = arr0;
    }
    wifenum = json["wifenum"]?.toInt();
    house = json["house"]?.toInt();
    if (json["word"] != null) {
      var v = json["word"];
      var arr0 = List<String>();
      v.forEach((v) {
        arr0.add(v.toString());
      });
      word = arr0;
    }
    if (json["mask"] != null) {
      var v = json["mask"];
      var arr0 = List<int>();
      v.forEach((v) {
        arr0.add(v.toInt());
      });
      mask = arr0;
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data["id"] = id;
    if (posx != null) {
      var v = posx;
      var arr0 = List();
      v.forEach((v) {
        arr0.add(v);
      });
      data["posx"] = arr0;
    }
    if (posy != null) {
      var v = posy;
      var arr0 = List();
      v.forEach((v) {
        arr0.add(v);
      });
      data["posy"] = arr0;
    }
    if (answer != null) {
      var v = answer;
      var arr0 = List();
      v.forEach((v) {
        arr0.add(v);
      });
      data["answer"] = arr0;
    }
    data["levelup"] = levelup;
    data["hero"] = hero;
    if (idiom != null) {
      var v = idiom;
      var arr0 = List();
      v.forEach((v) {
        arr0.add(v);
      });
      data["idiom"] = arr0;
    }
    data["wifenum"] = wifenum;
    data["house"] = house;
    if (word != null) {
      var v = word;
      var arr0 = List();
      v.forEach((v) {
        arr0.add(v);
      });
      data["word"] = arr0;
    }
    if (mask != null) {
      var v = mask;
      var arr0 = List();
      v.forEach((v) {
        arr0.add(v);
      });
      data["mask"] = arr0;
    }
    return data;
  }
}

class LocalLevelData {
  int id;
  int levelup;
  int hero;
  List<String> idiom;
  int wifenum;
  int house;
  List<String> words;
  // 0.normal 1.fixed 2.mask 3.no word
  List<int> types;

  bool hasWord(int idx) {
    return types[idx] != 3;
  }

  List<int> getIdiomIdx(int idx, bool isHor) {
    List<int> idiom = new List();
    if (hasWord(idx)) {
      idiom.add(idx);
      int col = idx % 9;
      int row = (idx / 9).floor();
      int dest = isHor ? col : row;
      final fun = (int destIdx, bool isFirst) {
        if (hasWord(destIdx)) {
          if (isFirst) {
            idiom.insert(0, destIdx);
          } else {
            idiom.add(destIdx);
          }
          return true;
        } else {
          return false;
        }
      };
      for (int i = dest - 1; i >= 0; --i) {
        int destIdx = isHor ? row * 9 + i : i * 9 + col;
        if (!fun(destIdx, true)) break;
      }
      for (int i = dest + 1; i < 9; ++i) {
        int destIdx = isHor ? row * 9 + i : i * 9 + col;
        if (!fun(destIdx, false)) break;
      }
    }
    return idiom;
  }

  bool hasIdiom(int idx, bool isHor) {
    return getIdiomIdx(idx, isHor).length == 4;
  }

  bool isRemoveable(int idx, bool isHor) {
    List<int> idxs = getIdiomIdx(idx, isHor);
    if (idxs.length == 4) {
      int cnt = 0;
      for (int i = 0; i < idxs.length; ++i) {
        if (hasIdiom(idxs[i], !isHor)) {
          ++cnt;
        }
      }
      return cnt < 2;
    }
    return false;
  }

  void addWord(int idx, String word) {
    words[idx] = word;
    types[idx] = 0;
  }

  void setWord(int idx, String word) {
    if (word.length > 0) {
      if (types[idx] == 3)
        types[idx] = 0;
      words[idx] = word.substring(0, 1);
    } else {
      types[idx] = 3;
      words[idx] = '';
    }
  }

  void rmWord(int idx) {
    words[idx] = '';
    types[idx] = 3;
  }

  void rmIdiom(int idx, bool isHor) {
    if (isRemoveable(idx, isHor)) {
      List<int> idxs = getIdiomIdx(idx, isHor);
      for (int idx in idxs) {
        if (!hasIdiom(idx, !isHor)) {
          rmWord(idx);
        }
      }
    }
  }

  void rmAllWord() {
    words.fillRange(0, 81, '');
    types.fillRange(0, 81, 3);
  }

  LocalLevelData.fromLevelData(LevelData data) {
    id = data.id;
    levelup = data.levelup;
    hero = data.hero;
    idiom = data.idiom;
    wifenum = data.wifenum;
    house = data.house;
    words = new List(81);
    words.fillRange(0, 81, "");
    types = new List(81);
    types.fillRange(0, 81, 3);
    int len = data.word.length;
    for (int i = 0; i < len; ++i) {
      int pos = data.posx[i] + (8 - data.posy[i]) * 9;
      bool isMask = data.mask.indexOf(i) != -1;
      bool isFixed = data.answer.indexOf(i) == -1;
      words[pos] = data.word[i];
      types[pos] = isMask ? 2: isFixed ? 1 : 0;
    }
  }

  LevelData toLevelData() {
    LevelData ld = new LevelData(
      id: id,
      levelup: levelup,
      hero: hero,
      idiom: idiom,
      wifenum: wifenum,
      house: house,
    );
    List<int> posx = new List();
    List<int> posy = new List();
    List<String> word = new List();
    List<int> mask = new List();
    List<int> answer = new List();
    int idx = 0;
    for (int i = 0; i < 81; ++i) {
      int type = types[i];
      if (type != 3) {
        word.add(words[i]);
        posx.add(i % 9);
        posy.add(8 - (i / 9).floor());
        switch (type) {
          case 0: {
            answer.add(idx);
          }
          break;
          case 1: {

          }
          break;
          case 2: {
            mask.add(idx);
          }
          break;
        }
        ++idx;
      }
    }
    ld.posx = posx;
    ld.posy = posy;
    ld.word = word;
    ld.mask = mask;
    ld.answer = answer;
    return ld;
  }
}
