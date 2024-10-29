import Cocoa
import FlutterMacOS
import ImageIO // Make sure to import ImageIO for kUTTypePNG

@main
class AppDelegate: FlutterAppDelegate {
    var window: NSWindow? // Define a property for the window

    override func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Access the main window from the app delegate
        guard let controller = NSApplication.shared.windows.first?.contentViewController as? FlutterViewController else {
            return
        }

        // Use FlutterPluginRegistry to get the binary messenger
        let screenshotChannel = FlutterMethodChannel(name: "screenshot_channel",
                                                     binaryMessenger: controller.engine.binaryMessenger)
        screenshotChannel.setMethodCallHandler { (call, result) in
            if call.method == "takeScreenshot" {
                self.takeScreenshot(result: result)
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

    }

    private func takeScreenshot(result: @escaping FlutterResult) {
        let displayID = CGMainDisplayID()
        if let screenshot = CGDisplayCreateImage(displayID) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HHmmss"
            let timestamp = formatter.string(from: Date())
            let filePath = "\(NSTemporaryDirectory())\(timestamp).png"
            let url = URL(fileURLWithPath: filePath)

            if let destination = CGImageDestinationCreateWithURL(url as CFURL, kUTTypePNG, 1, nil) {
                CGImageDestinationAddImage(destination, screenshot, nil)
                if CGImageDestinationFinalize(destination) {
                    result(filePath) // Return file path to Flutter
                } else {
                    result(FlutterError(code: "ERROR", message: "Failed to save screenshot", details: nil))
                }
            } else {
                result(FlutterError(code: "ERROR", message: "Failed to create image destination", details: nil))
            }
        } else {
            result(FlutterError(code: "ERROR", message: "Failed to capture screenshot", details: nil))
        }
    }

    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return false
    }
}