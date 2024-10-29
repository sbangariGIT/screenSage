import 'package:flutter/material.dart';
import 'package:screensage/pages/dashboard.dart';
import 'package:screensage/pages/splash.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:flutter/services.dart'; // For SystemNavigator.pop()
import 'dart:io';
import 'dart:async'; // Import for Timer
import 'package:window_manager/window_manager.dart'; // For window control

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    // Initialize the window manager (required to control the app window)
  await windowManager.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TrayListener, WindowListener {
  static const platform = MethodChannel('screenshot_channel');
  Timer? _timer; // Declare a Timer variable
  bool monitoring = false; // Variable to track screenshotting state

  @override
  void initState() {
    super.initState();
    initTray();
    initWindowsManager();
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

  initWindowsManager() {
    windowManager.addListener(this);
  }

  Future<void> initTray() async {
    // Initialize the tray manager
    await trayManager.setIcon(
      Platform.isWindows
          ? 'assets/icons/tray-icon.ico'
          : 'assets/icons/tray-icon.png',
    );

    // Generate the initial tray menu
    await _setTrayMenu();

    trayManager.addListener(this);
  }

  // Method to set or update the tray menu
  Future<void> _setTrayMenu() async {
    Menu menu = Menu(
      items: [
        MenuItem(
          key: 'show_window',
          label: 'Show Dashboard',
        ),
        MenuItem(
          key: 'start',
          label: 'Start Monitoring',
          disabled: monitoring, // Disabled if monitoring is true
        ),
        MenuItem(
          key: 'pause',
          label: 'Pause Monitoring',
          disabled: !monitoring, // Disabled if monitoring is false
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'exit_app',
          label: 'Exit App',
        ),
      ],
    );
    await trayManager.setContextMenu(menu);
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
    _timer?.cancel();
    print("Why am I being called?");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SplashScreen(),
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
        // Show the app window when "Show Dashboard" is clicked
        print('Show Window clicked');
        windowManager.setSkipTaskbar(false);
        windowManager.show();
        windowManager.focus();
        break;
      case 'start':
        // Start screenshot monitoring
        if (!monitoring) {
          print('Started taking screenshots!');
          _startScreenshotTimer();
          setState(() {
            monitoring = true; // Set the state to true
            _setTrayMenu();
          });
        }
        break;
      case 'pause':
        // Pause screenshot monitoring
        if (monitoring) {
          print('Paused screenshotting!');
          _stopScreenshotTimer();
          setState(() {
            monitoring = false; // Set the state to false
            _setTrayMenu();
          });
        }
        break;
      case 'exit_app':
        // Exit the app when "Exit App" is clicked
        quitApp();
        trayManager.destroy();
        windowManager.destroy();
        break;
    }
  }

  @override
  void onWindowClose() async {
    // Prevent the window from closing, hide it instead
    await windowManager.hide();
    await windowManager.setSkipTaskbar(true);
  }
}
