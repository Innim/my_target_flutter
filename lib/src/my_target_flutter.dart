import 'dart:async';

import 'package:flutter/services.dart';
import 'ad_status_listener.dart';

// TODO: docs
class MyTargetFlutter {
  final bool isDebug;
  MyTargetFlutter({required this.isDebug});

  static const MethodChannel _channel = MethodChannel('my_target_flutter');

  static const _methodInitialize = 'initialize';
  static const _methodCreateInterstitialAd = 'createInterstitialAd';
  static const _methodLoad = 'load';
  static const _methodShow = 'show';
// TODO: docs
  Future<void> initialize({bool? useDebugMode, String? testDevices}) async {
    await _channel.invokeMethod(_methodInitialize,
        _getInitialData(useDebugMode ?? isDebug, testDevices));
  }

  // TODO: docs
  Future<InterstitialAd> createInterstitialAd(int slotId) async {
    final id = await _channel.invokeMethod<String>(
      _methodCreateInterstitialAd,
      {'slotId': slotId},
    );

    // TODO: check for null and process a error
    return InterstitialAd(this, id!);
  }

  Future<void> _load(String uid) async {
    await _channel.invokeMethod(_methodLoad, uid);
  }

  Future<void> _show(String uid) async {
    await _channel.invokeMethod(_methodShow, uid);
  }

  Map<String, dynamic> _getInitialData(bool useDebugMode, String? testDevices) {
    return <String, dynamic>{
      'useDebugMode': useDebugMode,
      'testDevices': testDevices,
    };
  }
}

class InterstitialAd {
  final MyTargetFlutter _plugin;
  final String uid;

  final _listeners = <AdStatusListener>{};

  InterstitialAd(this._plugin, this.uid);

  void load() {
    _plugin._load(uid);
  }

  void show() {
    _plugin._show(uid);
  }

  void addListener(AdStatusListener listener) {
    _listeners.add(listener);
  }

  void removeListener(AdStatusListener listener) {
    _listeners.remove(listener);
  }

  void clearListeners() {
    _listeners.clear();
  }
}
