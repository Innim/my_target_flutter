import 'dart:async';

import 'package:flutter/services.dart';

import 'ad_status_listener.dart';

/// Class for implementing MyTarget ads.
class MyTargetFlutter {
  final bool isDebug;

  MyTargetFlutter({required this.isDebug});

  static const MethodChannel _channel = MethodChannel('my_target_flutter');

  static const _methodInitialize = 'initialize';
  static const _methodCreateInterstitialAd = 'createInterstitialAd';
  static const _methodLoad = 'load';
  static const _methodShow = 'show';

  /// Initialising MyTarget ads. If[useDebugMode] = true
  /// and [testDevices] != null will show test ads.
  Future<void> initialize({bool? useDebugMode, String? testDevices}) async {
    await _channel.invokeMethod(_methodInitialize,
        _getInitialData(useDebugMode ?? isDebug, testDevices));
  }

  /// Creating an Interstitial ads for [slotId]
  Future<InterstitialAd> createInterstitialAd(int slotId) async {
    final uid = await _channel.invokeMethod<String>(
      _methodCreateInterstitialAd,
      {'slotId': slotId},
    );

    // TODO: check for null and process a error
    return InterstitialAd(this, uid!);
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
