import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:ble_scanner/ble_scanner.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  BleStatus _bleStatus;
  String    _codeValue = '';

  @override
  void initState() {
    super.initState();

    BleScanner().startScan();

    BleScanner().eventOnListen(
      onBLEStatus: (status) async {
        print('status $status');
        setState(() {
          _bleStatus = status;
        });
      },
      onBLEScanResult: (codeValue) async {
        print('scan code: $codeValue');
        setState(() {
          _codeValue = codeValue;
        });
      }
    );

    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await BleScanner.platformVersion;
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
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Running on: $_platformVersion\n'),
              Text('BLE Status: $_bleStatus\n'),
              Text('Scan Result: $_codeValue\n'),
            ],
          ),
        ),
      ),
    );
  }
}
