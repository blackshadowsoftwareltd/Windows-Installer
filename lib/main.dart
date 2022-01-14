import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'installer/installer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setSize(const Size(600, 400));
    await windowManager.setMaximumSize(const Size(650, 450));
    await windowManager.setMinimumSize(const Size(600, 400));
    await windowManager.show();
  });
  runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, home: InstallerScreen()));
}
