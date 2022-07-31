import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

import 'ad_status_listener.dart';
import 'ad_types/base_interstitial_ad.dart';

/// Implementing displaying MyTarget ads, currently supported by Interstitial Ads only.
class MyTargetFlutter {
  static const MethodChannel _channel = MethodChannel('my_target_flutter');
  static const channel = EventChannel('my_target_flutter/ad_listener');

  static const _methodInitialize = 'initialize';
  static const _methodCreateInterstitialAd = 'createInterstitialAd';
  static const _methodCreateRewardedAd = 'createRewardedAd';
  static const _methodCreateBannerAd = 'createBannerAd';
  static const _methodLoad = 'load';
  static const _methodShow = 'show';

  final bool isDebug;

  Stream<AdEventMessage>? _stream;

  MyTargetFlutter({required this.isDebug});

  Stream<AdEventMessage> get adListenStream => _stream ??= channel
          .receiveBroadcastStream()
          .cast<Map<dynamic, dynamic>>()
          .transform(StreamTransformer.fromHandlers(
        handleData: (event, sink) {
          final data = AdEventMessage.fromJson(event.cast<String, dynamic>());
          sink.add(data);
        },
      ));

  /// Initializing MyTarget ads.
  /// [useDebugMode] enabling debug mode.
  /// Pass the test device ID to [testDevices] if needed.
  /// For full details on test mode see [https://target.my.com/help/partners/mob/debug/en]
  Future<void> initialize({bool? useDebugMode, String? testDevices}) async {
    await _channel.invokeMethod(
        _methodInitialize, _getInitialData(useDebugMode ?? isDebug, testDevices));
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

  /// Create an Rewarded ads with [slotId]
  Future<RewardedAd> createRewardedAd(int slotId) async {
    final uid = await _channel.invokeMethod<String>(
      _methodCreateRewardedAd,
      {'slotId': slotId},
    );
    if (uid == null) {
      throw FlutterError('Can not create Interstitial ad');
    } else {
      return RewardedAd(this, uid);
    }
  }

  Future<dynamic> createBannerAd(int slotId) async {
    final uid = await _channel.invokeMethod<String>(
      _methodCreateBannerAd,
      {'slotId': slotId},
    );
    print('BANNER COMES: $uid');
    // if (uid == null) {
    //   throw FlutterError('Can not create Interstitial ad');
    // } else {
    //   return RewardedAd(this, uid);
    // }
  }

  Future<void> load(String uid) async {
    await _channel.invokeMethod(_methodLoad, uid);
  }

  Future<void> show(String uid) async {
    await _channel.invokeMethod(_methodShow, uid);
  }

  Map<String, dynamic> _getInitialData(bool useDebugMode, String? testDevices) {
    return <String, dynamic>{
      'useDebugMode': useDebugMode,
      'testDevices': testDevices,
    };
  }
}
