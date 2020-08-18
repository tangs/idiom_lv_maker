import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dart:io';

import './web_tools.dart';

class Tools {
  static Future<String> getFileText() async {
    if (kIsWeb) {
      // WebTools.getFileText(callback);
      return WebTools.getFileText();
    } else if (Platform.isMacOS) {
      // mac platform
      const platform = const MethodChannel('tangs.com/lv_maker');
      try {
        final String str = await platform.invokeMethod('openFile');
        return Future.value(str);
      } catch (e) {
        return Future.error(e);
      }
    }
    // TODO other platform.
    return Future.error('can not support current platform.');
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
