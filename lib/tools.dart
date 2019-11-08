import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dart:io';

import './web_tools.dart';

class Tools {
  static void getFileText(Function callback) async {
    if (kIsWeb) {
      WebTools.getFileText(callback);
    } else if (Platform.isMacOS) {
      // mac platform
      const platform = const MethodChannel('tangs.com/lv_maker');
      try {
        final String str = await platform.invokeMethod('openFile');
        // str = '$result';
        int error = str.length == 0 ? 1 : 0;
        callback(error, str);
      } on PlatformException catch (e) {
        debugPrint("Failed: '${e.message}'.");
        callback(2, e.message);
      }
    }
  }

  static void saveFile(String txt) async {
    // mac platform
    if (kIsWeb) {
      WebTools.saveFile(txt);
    } else if (Platform.isMacOS) {
      const platform = const MethodChannel('tangs.com/lv_maker');
      try {
        int ret = await platform.invokeMethod('saveFile', txt);
        if (ret != 0) {
          debugPrint("Save Failed.");  
        }
      } on PlatformException catch (e) {
        debugPrint("Failed: '${e.message}'.");
      }
    }
  }
}
