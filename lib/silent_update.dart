import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;

class SilentUpdate {
  static const MethodChannel _channel = MethodChannel('silent_update');
  Directory? dir;
  final Dio _dio = Dio();
  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<bool> _requestInstallPermissions() async {
    if (!(await Permission.storage.isGranted)) {
      await Permission.storage.request();
    }

    return await Permission.storage.isGranted;
  }

  Future<String?> startAppDownload(String url, String fileName,
      Function(int, int) onReceiveProgress, String packageName) async {
    dir = await getApplicationSupportDirectory();
    final isPermissionStatusGranted = await _requestInstallPermissions();
    if (isPermissionStatusGranted) {
      final savePath = path.join(dir!.path, fileName);
      await _startAppDownload(savePath, url, onReceiveProgress, packageName);
    } else {
      print("Permission Error Encountered");
      return 'Permission Error';
    }
  }

  Future<void> _startAppDownload(String savePath, String url,
      Function(int, int) onReceiveProgress, String packageName) async {
    Map<String, dynamic> result = {
      'isSuccess': false,
      'filePath': null,
      'error': null,
    };
    try {
      final response = await _dio.download(url, savePath,
          onReceiveProgress: onReceiveProgress);
      result['isSuccess'] = response.statusCode == 200;
      result['filePath'] = savePath;
      _installApp(packageName, savePath);
    } catch (ex) {
      result['error'] = ex.toString();
      print(ex.toString());
    } finally {
      print("SilentUpdatePlugin:" + result.toString());
    }
  }

  static Future<bool> _installApp(String packageName, String apkPath) async {
    await _channel.invokeMethod(
        'installApp', {'packageName': packageName, 'apkPath': apkPath});
    return true;
  }
}
