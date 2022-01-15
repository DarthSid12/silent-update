import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:silent_update/silent_update.dart';

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
  String _progress = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  void _onReceiveProgress(int received, int total) {
    if (total != -1) {
      setState(() {
        _progress = (received / total * 100).toStringAsFixed(0) + "%";
        print(_progress);
      });
    }
  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await SilentUpdate.platformVersion ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                    SilentUpdate().startAppDownload(
                        'https://firebasestorage.googleapis.com/v0/b/dan-lock.appspot.com/o/app-release.apk?alt=media&token=08b1bc1b-d637-4981-83ce-dd21b9448fd1',
                        "SilentUpdate.apk",
                        _onReceiveProgress,
                        'com.silent.update.silent_update_example');
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
