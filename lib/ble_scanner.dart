import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef Future<dynamic> MessageHandler(dynamic message);

enum BleStatus {
  powerError,
  discovering,
  discovered,
  discoverNotFound,
  connectFail,
  connectSuccess,
  disconnect
}

class BleScanner {
  static const MethodChannel _channel = const MethodChannel('ble_scanner');

  factory BleScanner() {
    if (_instance == null) {
      MethodChannel methodChannel = MethodChannel('plugins.flutter.io/ble/methods');

      _instance = BleScanner.private(methodChannel);
    }

    return _instance;
  }

  @visibleForTesting
  BleScanner.private(this._methodChannel);

  final MethodChannel _methodChannel;
  static BleScanner _instance;

  MessageHandler _onBLEStatus;
  MessageHandler _onBLEScanResult;

  void eventOnListen({
    MessageHandler onBLEStatus,
    MessageHandler onBLEScanResult
  }){
    _onBLEStatus = onBLEStatus;
    _onBLEScanResult = onBLEScanResult;

    _methodChannel.setMethodCallHandler(_handleMethod);
  }

  Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case "bleStatus":

        int status = call.arguments['status'];
        return _onBLEStatus(BleStatus.values[status]);
        break;
      case "scanResult":
        return _onBLEScanResult(call.arguments['codeValue']);
        break;
      default:
        throw UnsupportedError("Unrecognized JSON message");
        break;
    }
  }

  Future startScan() async {
    _methodChannel.invokeMethod('startScan');
  }

  Future stopScan() async {
    _methodChannel.invokeMethod('stopScan');
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}