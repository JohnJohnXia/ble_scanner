import 'dart:async';

import 'package:flutter/services.dart';

class BleScanner {
  static const MethodChannel _channel =
      const MethodChannel('ble_scanner');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
