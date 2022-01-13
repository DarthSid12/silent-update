import 'dart:async';

import 'package:flutter/services.dart';

class SilentUpdate {
  static const MethodChannel _channel = MethodChannel('silent_update');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<bool> installApp(String packageName, String apkPath) async {
    // _channel.i
    print("hey");
    await _channel.invokeMethod(
        'installApp', {'packageName': packageName, 'apkPath': apkPath});
    return true;
  }
}
