import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationDidFinishLaunching(_ notification: Notification) {
    let controller : FlutterViewController = mainFlutterWindow?.contentViewController as! FlutterViewController
    let channel = FlutterMethodChannel.init(name: "tangs.com/lv_maker", binaryMessenger: controller.engine.binaryMessenger)
    channel.setMethodCallHandler({
      (_ call: FlutterMethodCall, _ result: FlutterResult) -> Void in
      if ("openFile" == call.method) {
        self.openFile(result: result);
      } else if ("saveFile" == call.method) {
        let arguments = call.arguments
        if arguments is String {
          let txt = arguments as! String
          self.saveFile(result: result, txt: txt)
        }
      }
    });
  }
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {

    return true
  }
  
  private func openFile(result: FlutterResult) {
    let openPanel = NSOpenPanel()
    openPanel.title = "Choose a .json file";
    openPanel.showsResizeIndicator = true;
    openPanel.allowsMultipleSelection = false
    openPanel.canChooseDirectories = false
    openPanel.canCreateDirectories = false
    openPanel.canChooseFiles = true
    openPanel.allowedFileTypes = ["json"];
    
    if (openPanel.runModal() == NSApplication.ModalResponse.OK) {
      let result1 = openPanel.urls
        
      if (result1.count > 0) {
        let file = result1[0]
//        result(String(path));
        do {
          let txt = try String(contentsOf: file, encoding: .utf8)
          result(txt)
        }
        catch {
          result("");
        }
      }
    } else {
        result("");
    }
  }
  
  private func saveFile(result: FlutterResult, txt: String) {
    let savePanel = NSSavePanel()
    savePanel.title = "save file";
    savePanel.showsResizeIndicator = true;
    savePanel.canCreateDirectories = true
    savePanel.allowedFileTypes = ["json"];
    if (savePanel.runModal() == NSApplication.ModalResponse.OK) {
      let file = savePanel.url
      if (file != nil) {
        do {
          try txt.write(to: file!, atomically: false, encoding: .utf8);
          result(0);
        }
        catch {
          result(1);
        }
      }
    }
  }
}
