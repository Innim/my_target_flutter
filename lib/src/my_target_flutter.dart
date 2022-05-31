import 'dart:async';

import 'package:flutter/services.dart';

import 'ad_status_listener.dart';

class MyTargetFlutter {
  final bool isDebug;
  MyTargetFlutter({required this.isDebug});

  static const MethodChannel _channel = MethodChannel('my_target_flutter');
  static const _methodInitialize = 'initialize';
  static const _methodCreateInterstitialAd = 'create_interstitial_ad';
  // static const _methodLoad = 'load';
  // static const _methodShow = 'show';

  Future<void> initialize({bool? useDebugMode, String? testDevices}) async {
    await _channel.invokeMethod(_methodInitialize,
        _getInitialData(useDebugMode ?? isDebug, testDevices));
  }

  Future<InterstitialAd> createInterstitialAd(int slotId) async {
    final id = await _channel.invokeMethod(_methodCreateInterstitialAd, slotId);
    return InterstitialAd(id);
  }

  Future<void> _load(String uid) async {
    // TODO: await _channel.invokeMethod(_load);
  }

  Future<void> _show(String uid) async {
    // TODO: await _channel.invokeMethod(_show);
  }

  Map<String, dynamic> _getInitialData(bool useDebugMode, String? testDevices) {
    return <String, dynamic>{
      'useDebugMode': useDebugMode,
      'testDevices': testDevices,
    };
  }
}

class InterstitialAd {
  void load() {
    // TODO
  }

  void show() {
    // TODO
  }

  void addListener(AdStatusListener listener) {
    // TODO
  }

  void removeListener(AdStatusListener listener) {
    // TODO
  }
}
