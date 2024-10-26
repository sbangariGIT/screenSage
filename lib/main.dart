import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:flutter/services.dart'; // For SystemNavigator.pop()
import 'dart:io';
import 'dart:async'; // Import for Timer

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TrayListener {
  static const platform = MethodChannel('screenshot_channel');
  Timer? _timer; // Declare a Timer variable
  bool monitoring = false; // Variable to track screenshotting state

  @override
  void initState() {
    super.initState();
    initTray();
  }

  void _startScreenshotTimer() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      takeScreenshot(); // Call the screenshot function every minute
    });
  }

  void _stopScreenshotTimer() {
    _timer?.cancel(); // Stop the timer
    _timer = null; // Clear the timer
  }

  Future<void> takeScreenshot() async {
    try {
      final result = await platform.invokeMethod('takeScreenshot');
      print('Screenshot saved at: $result');
    } on PlatformException catch (e) {
      print("Failed to take screenshot: '${e.message}'.");
    }
  }

  Future<void> initTray() async {
    // Initialize the tray manager
    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/icons/tray-icon.ico'
          : 'assets/icons/tray-icon.png',
    );
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: 'Show Dashboard',
        ),
        MenuItem(
          key: 'start',
          label: 'Start Monitoring',
          disabled: monitoring,
        ),
        MenuItem(
          key: 'pause',
          label: 'Pause Monitoring',
          disabled: !monitoring,
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit App',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);

    trayManager.addListener(this);
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    super.dispose();
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Tray Manager Example')),
        body: const Center(
          child: Text('Right-click the tray icon to interact with the app'),
        ),
      ),
    );
  }

@override
void onTrayIconMouseDown() {
  trayManager.popUpContextMenu(); // Open the context menu
}

  void quitApp() {
    if (Platform.isAndroid || Platform.isIOS) {
      SystemNavigator.pop(); // Closes the app on Android or iOS
    } else {
      exit(0); // Closes the app on desktop platforms
    }
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_window':
        // Show the app when "Show Window" is clicked
        print('Show Window clicked');
        break;
      case 'start':
        // Show the app when "Show Window" is clicked
        if (!monitoring) {
          print('Started taking screenshots!');
          monitoring = true; // Set the state to true
          _startScreenshotTimer();
          initTray();
        }
        
        break;
      case 'pause':
        // Show the app when "Show Window" is clicked
        if (monitoring) {
          print('pause the screenshoting!');
          _stopScreenshotTimer();
          monitoring = false; // Set the state to false
          initTray();
        }
        break;
      case 'exit_app':
        // Exit the app when "Exit App" is clicked
        quitApp();
        trayManager.destroy();
        break;
    }
  }
}
