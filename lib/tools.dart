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
}
