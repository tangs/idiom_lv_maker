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
