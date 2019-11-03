import 'dart:html';

class Tools {
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
          callback(result);
        });
        reader.readAsText(file);
      }
    });
  }

  static void saveFile() {
    // Assuming your HTML has an empty anchor with ID 'myLink'
    var link = querySelector('#test') as AnchorElement;
    var myData = [ "Line 1\n", "Line 2\n", "Line 3\n"];
    // Plain text type, 'native' line endings
    var blob = new Blob(myData, 'text/plain', 'native');
    link.download = "1.txt";
    link.href = Url.createObjectUrlFromBlob(blob).toString();
    link.text = "Download Now!";
    link.click();
  }
}
