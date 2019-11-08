import 'dart:html';

class WebTools {
  static void getFileText(Function callback) async {
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files.length == 1) {
        final file = files[0];
        final reader = new FileReader();

        reader.onLoadEnd.listen((e) {
          final result = reader.result;
          callback(0, result);
        });
        reader.readAsText(file);
      }
    });
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
