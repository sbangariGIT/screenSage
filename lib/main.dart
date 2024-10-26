import 'package:flutter/material.dart' hide MenuItem;
import 'package:tray_manager/tray_manager.dart';
import 'package:flutter/services.dart'; // For SystemNavigator.pop()
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TrayListener {
  @override
  void initState() {
    super.initState();
    initTray();
  }

  Future<void> initTray() async {
    // Initialize the tray manager
    await trayManager.setIcon(
      Platform.isWindows ? 'assets/icons/tray-icon.ico' : 'assets/icons/tray-icon.png',
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
          disabled: true,
        ),
        MenuItem(
          key: 'pause',
          label: 'Pause Monitoring',
          disabled: true,
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Tray Manager Example')),
        body: Center(
          child: Text('Right-click the tray icon to interact with the app'),
        ),
      ),
    );
  }

  // Handle tray icon menu click events
  @override
  void onTrayIconMouseDown() {
    print('Tray icon clicked!');
    trayManager.popUpContextMenu();
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
      case 'exit_app':
        // Exit the app when "Exit App" is clicked
        quitApp();
        trayManager.destroy();
        break;
    }
  }
}
