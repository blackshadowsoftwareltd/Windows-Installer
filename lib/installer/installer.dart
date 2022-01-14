import 'dart:io';
import 'package:windows_installer/custom_button.dart';
import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/services.dart' show SystemNavigator, rootBundle;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class InstallerScreen extends StatefulWidget {
  const InstallerScreen({Key? key}) : super(key: key);

  @override
  State<InstallerScreen> createState() => _InstallerScreenState();
}

const _appName = 'AppName';
const _shortcutExeZipFilePath = 'shortcut.exe.zip';

class _InstallerScreenState extends State<InstallerScreen> {
  bool _isShortcut = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              /// App Name
              const Text(_appName,
                  style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87)),

              /// Create a Desktop shortcut checkbox
              KCustomButton(
                  radius: 8,
                  borderColor: Colors.transparent,
                  widget: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 2),
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Create a Desktop shortcut ',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87)),
                            Checkbox(
                                checkColor: Colors.black,
                                activeColor: Colors.white,
                                value: _isShortcut,
                                onChanged: (value) =>
                                    setState(() => _isShortcut = value!))
                          ])),
                  onPressed: () => setState(() => _isShortcut = !_isShortcut)),

              /// Task
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                /// Installation
                KCustomButton(
                    radius: 12,
                    widget: const SizedBox(
                        width: 120,
                        height: 40,
                        child: Center(
                            child: Text('Install',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18)))),
                    onPressed: () async {
                      ///
                      /// I will work on the release build. not debug mode.
                      ///
                      final _path = await getDownloadsDirectory();
                      final _desktop = _path!.path.split(r'\');
                      sendToProgramFile()
                          .then((value) => sendToShortcut().then((value) {
                                if (_isShortcut) {
                                  sendToDesktopShortcut(
                                      'C:\\Users\\${_desktop[2]}\\OneDrive\\Desktop');
                                }
                                return showMessage(
                                    'The $_appName successfully installed');
                              }));
                    }),

                /// Remove
                KCustomButton(
                    radius: 12,
                    widget: const SizedBox(
                        width: 120,
                        height: 40,
                        child: Center(
                            child: Text('Uninstall',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18)))),
                    onPressed: () async {
                      ///
                      /// It will work on the release build. not debug mode.

                      try {
                        /// from program file
                        await removeFromProgramFile();

                        /// from start menu & the desktop
                        await removeAllShortcuts();
                        showMessage(
                            'The ' + _appName + ' successfully removed');
                      } catch (e) {
                        showMessage(e.toString());
                      }
                    }),

                /// Exit
                KCustomButton(
                    radius: 12,
                    widget: const SizedBox(
                        width: 120,
                        height: 40,
                        child: Center(
                            child: Text('Exit',
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 18)))),
                    onPressed: () {
                      ///
                      /// It will work on the release build. not debug mode.
                      SystemNavigator.pop();
                      exit(0);
                    })
              ])
            ])));
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }

  Future<void> sendToProgramFile() async {
    /// release file path (assets file)
    final _fileX = await getImageFileFromAssets('Release.zip');
    final bytesX = File(_fileX.path).readAsBytesSync();
    final archiveX = ZipDecoder().decodeBytes(bytesX);
    for (final file in archiveX) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File('C:\\Program Files\\$_appName/' + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('C:\\Program Files\\$_appName/' + filename)
            .create(recursive: true);
      }
    }
  }

  Future<void> sendToShortcut() async {
    /// shortcut for start menu (assets file)
    final _fileZ = await getImageFileFromAssets(_shortcutExeZipFilePath);
    final bytesZ = File(_fileZ.path).readAsBytesSync();
    final archiveZ = ZipDecoder().decodeBytes(bytesZ);
    for (final file in archiveZ) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File('C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs/' +
            filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs/' +
                filename)
            .create(recursive: true);
      }
    }
  }

  /// createing desktop shortcut
  /// C:\Users\nextr\OneDrive\Desktop\
  Future<String> sendToDesktopShortcut(String path) async {
    final _fileZ = await getImageFileFromAssets(_shortcutExeZipFilePath);

    ////
    try {
      final bytesZ = File(_fileZ.path).readAsBytesSync();
      final archiveZ = ZipDecoder().decodeBytes(bytesZ);
      for (final file in archiveZ) {
        final filename = file.name;
        if (file.isFile) {
          final data = file.content as List<int>;
          File('$path/' + filename)
            ..createSync(recursive: true)
            ..writeAsBytesSync(data);
        } else {
          Directory('$path/' + filename).create(recursive: true);
        }
      }
      return 'done';
    } catch (e) {
      return 'failed';
    }
  }

  Future<void> removeFromProgramFile() async {
    final _dir = Directory('C:\\Program Files\\$_appName');
    if (_dir.existsSync()) {
      _dir.deleteSync(recursive: true);
    }
  }

  Future<void> removeAllShortcuts() async {
    final _path = await getDownloadsDirectory();
    final _desktop = _path!.path.split(r'\');
    final desktopPath = 'C:\\Users\\${_desktop[2]}\\OneDrive\\Desktop/';

    ///
    final _fileZ = await getImageFileFromAssets(_shortcutExeZipFilePath);
    final bytesZ = File(_fileZ.path).readAsBytesSync();
    final archiveZ = ZipDecoder().decodeBytes(bytesZ);
    for (final file in archiveZ) {
      final filename = file.name;
      if (file.isFile) {
        /// remove from start menu
        final _file = File(
            'C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs/' +
                filename);
        if (_file.existsSync()) {
          _file.deleteSync(recursive: true);
        }

        /// remove from Desktop
        final _deskFile = File(desktopPath + filename);
        if (_deskFile.existsSync()) {
          _deskFile.deleteSync(recursive: true);
        }
      }
    }
  }

  showMessage(String message) => showDialog(
      context: context,
      builder: (context) {
        return Dialog(
            child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(message, style: const TextStyle(fontSize: 22)),
                  const SizedBox(height: 30),
                  KCustomButton(
                      radius: 10,
                      borderColor: Colors.transparent,
                      widget: const SizedBox(
                          height: 40,
                          width: double.infinity,
                          child: Center(
                              child: Text('Close',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: .5)))),
                      onPressed: () => Navigator.pop(context))
                ])));
      });
}
