import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'ad_status_listener.dart';

/// Implementing displaying MyTarget ads, currently supported by Interstitial Ads only.
class MyTargetFlutter {
  static const _listenChannelName = 'my_target_flutter/ad_listener';
  final bool isDebug;

  MyTargetFlutter({required this.isDebug});

  static const MethodChannel _channel = MethodChannel('my_target_flutter');
  static const channel = EventChannel(_listenChannelName);

  static const _methodInitialize = 'initialize';
  static const _methodCreateInterstitialAd = 'createInterstitialAd';
  static const _methodLoad = 'load';
  static const _methodShow = 'show';

  Stream<AdEventMessage>? _stream;

  Stream<AdEventMessage> get stream {
    return _stream ??= channel
        .receiveBroadcastStream()
        .cast<Map<dynamic, dynamic>>()
        .transform(StreamTransformer.fromHandlers(
      handleData: (event, sink) {
        final data = AdEventMessage.fromJson(event.cast<String, dynamic>());
        sink.add(data);
      },
    ));
  }

  /// Initialising MyTarget ads.
  /// [useDebugMode] enabling debug mode.
  /// Pass the test device ID to [testDevices] if needed.
  /// For full details on test mode see [https://target.my.com/help/partners/mob/debug/en]
  Future<void> initialize({bool? useDebugMode, String? testDevices}) async {
    await _channel.invokeMethod(_methodInitialize,
        _getInitialData(useDebugMode ?? isDebug, testDevices));
  }

  /// Create an Interstitial ads with [slotId]
  Future<InterstitialAd> createInterstitialAd(int slotId) async {
    final uid = await _channel.invokeMethod<String>(
      _methodCreateInterstitialAd,
      {'slotId': slotId},
    );
    if (uid == null) {
      throw FlutterError('Can not create Interstitial ad');
    } else {
      return InterstitialAd(this, uid);
    }
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

  InterstitialAd(this._plugin, this.uid) {
    _plugin.stream.listen(_handleMessage);
  }

  Future<void> _handleMessage(AdEventMessage data) async {
    if (data.uid == uid) {
      _listeners.handleEvent(data);
    }
  }

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

extension SetAdStatusListenerExtention on Set<AdStatusListener> {
  void handleEvent(AdEventMessage data) {
    for (final listener in this) {
      listener.handleEvent(data);
    }
  }
}
