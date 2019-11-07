import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dart:io';
// import 'dart:html';

class Tools {
  static void getFileText(Function callback) async {
    // // web platform
    // InputElement uploadInput = FileUploadInputElement();
    // uploadInput.click();

    // uploadInput.onChange.listen((e) {
    //   final files = uploadInput.files;
    //   if (files.length == 1) {
    //     final file = files[0];
    //     final reader = new FileReader();

    //     reader.onLoadEnd.listen((e) {
    //       final result = reader.result;
    //       callback(0, result);
    //     });
    //     reader.readAsText(file);
    //   }
    // });
    // // web

    if (Platform.isMacOS) {
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
    // // Assuming your HTML has an empty anchor with ID 'myLink'
    // var link = querySelector('#downloader') as AnchorElement;
    // var myData = [txt];
    // // Plain text type, 'native' line endings
    // var blob = new Blob(myData, 'text/plain', 'native');
    // link.download = "IdiomConfig.json";
    // link.href = Url.createObjectUrlFromBlob(blob).toString();
    // link.text = "Download Now!";
    // link.click();

    // mac platform
    if (Platform.isMacOS) {
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
