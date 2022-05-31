import 'dart:async';

import 'package:flutter/services.dart';

class MyTargetFlutter {
  final bool isDebug;
  MyTargetFlutter({required this.isDebug});

  static const MethodChannel _channel = MethodChannel('my_target_flutter');
  static const _initial = 'initial';
  static const _load = 'load';
  static const _show = 'show';

  Future<void> initialize(int slotId, bool useDebugMode,
      {String? testDevices}) async {
    await _channel.invokeMethod(
        _initial, _getInitialData(slotId, useDebugMode, testDevices));
  }

  Future<void> load() async {
    await _channel.invokeMethod(_load);
  }

  Future<void> show() async {
    await _channel.invokeMethod(_show);
  }

  Map<String, dynamic> _getInitialData(
      int slotId, bool useDebugMode, String? testDevices) {
    return <String, dynamic>{
      'slotId': slotId,
      'useDebugMode': useDebugMode,
      'testDevices': testDevices,
    };
  }
}
