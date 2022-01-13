import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:silent_update/silent_update.dart';
import 'package:path/path.dart' as path;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  Directory? dir;
  final Dio _dio = Dio();
  String _progress = '';

  Future<void> _startDownload(String savePath) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };
    print(3);
    try {
      final response = await _dio.download(
          'https://firebasestorage.googleapis.com/v0/b/dan-lock.appspot.com/o/app-release.apk?alt=media&token=08b1bc1b-d637-4981-83ce-dd21b9448fd1',
          savePath,
          onReceiveProgress: _onReceiveProgress);
      print(4);
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
      SilentUpdate.installApp('com.silent.update.silent_update_example',
          path.join(dir!.path, "TestAP.apk"));
    } catch (ex) {
      result['error'] = ex.toString();
    } finally {
      print(result);
    }
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
        print(_progress);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Future<bool> _requestPermissions() async {
    if (!(await Permission.storage.isGranted)) {
      await Permission.storage.request();
    }

    return await Permission.storage.isGranted;
  }

  void _download(String url) async {
    // final status = await Permission.storage.request();
    // if (status.isGranted) {
    dir = await getApplicationSupportDirectory();
    // print(dir!.parent);
    // print(dir!.absolute);
    // print(dir!.uri);
    // return;
    final isPermissionStatusGranted = await _requestPermissions();
    print(1);
    if (isPermissionStatusGranted) {
      print(2);
      final savePath = path.join(dir!.path, "TestAP.apk");
      await _startDownload(savePath);
    } else {
      // handle the scenario when user declines the permissions
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await SilentUpdate.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    // SilentUpdate.installApp('', '');
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Running on: $_platformVersion\n'),
              ElevatedButton(
                  onPressed: () {
                    _download(
                      'https://internal1.4q.sk/flutter_hello_world.apk',
                    );
                  },
                  child: Text("Download")),
              Text(
                'Download progress:',
              ),
              Text(
                '$_progress',
                // style: Theme.of(context).textTheme.display1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
