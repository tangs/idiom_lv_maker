import 'dart:html';

class WebTools {
  static Future<String> getFileText() async {
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.click();
    await for (final _ in uploadInput.onChange) {
      final files = uploadInput.files;
      if (files.length == 1) {
        final file = files[0];
        final reader = new FileReader();
        reader.readAsText(file);
        await for (final _ in reader.onLoadEnd) {
          return Future.value(reader.result);
        }
        return Future.error('read fail1.');
        // reader.onLoadEnd.listen((e) {
        //   final result = reader.result;
        //   // callback(0, result);
        // });
      }
      return Future.error('read fail2.');
    }
    return Future.error('read fail3.');
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
  }

  static void saveFile(String txt) async {
    // Assuming your HTML has an empty anchor with ID 'myLink'
    AnchorElement link = querySelector('#downloader') as AnchorElement;
    var myData = [txt];
    // Plain text type, 'native' line endings
    Blob blob = new Blob(myData, 'application/json', 'native');
    link.download = "IdiomConfig.json";
    link.href = Url.createObjectUrlFromBlob(blob).toString();
    link.text = "Download Now!";
    // debugPrint(link.protocol);
    link.click();
  }
}
