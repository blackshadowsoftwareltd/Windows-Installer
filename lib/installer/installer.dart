import 'dart:io';
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

class _InstallerScreenState extends State<InstallerScreen> {
  bool _isShortcut = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade400,
      body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
            const Text('App Name',
                style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Create a Desktop shortcut ',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Checkbox(
                      checkColor: Colors.black,
                      activeColor: Colors.white,
                      value: _isShortcut,
                      onChanged: (value) async {
                        _isShortcut = value!;
                        setState(() {});
                      })
                ])
          ])),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            ///
            /// I will work on the release build. not debug mode.
            ///
            final _path = await getDownloadsDirectory();
            final _desktop = _path!.path.split(r'\');
            sendToProgramFile().then((value) => sendToShortcut().then((value) {
                  if (_isShortcut) {
                    sendToDesktopShortcut(context,
                        'C:\\Users\\${_desktop[2]}\\OneDrive\\Desktop');
                  }
                  return showDialog(
                      context: context,
                      builder: (context) => const Dialog(
                              child: Padding(
                            padding: EdgeInsets.all(30),
                            child: Text('Installation completed',
                                style: TextStyle(fontSize: 25)),
                          ))).then((value) async => Future.delayed(
                      const Duration(seconds: 3),
                      () => Navigator.pop(context)));
                }));
            await Future.delayed(const Duration(seconds: 5), () {
              SystemNavigator.pop();
              exit(0);
            });
          },
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          label: const Text(
            'Install',
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20),
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
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
        File('C:\\Program Files\\AppName/' + filename)
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('C:\\Program Files\\AppName/' + filename)
            .create(recursive: true);
      }
    }
  }

  Future<void> sendToShortcut() async {
    /// shortcut for start menu (assets file)
    final _fileZ = await getImageFileFromAssets('shortcut.exe.zip');
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
  Future<String> sendToDesktopShortcut(context, String path) async {
    final _fileZ = await getImageFileFromAssets('shortcut.exe.zip');

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
}
