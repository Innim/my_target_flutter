import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:my_target_flutter/src/extensions.dart';

import 'ad_status_listener.dart';

// Typedefs here for better user experience while using
// this package

typedef RewardedAd = _BaseInterstitialAd;
typedef InterstitialAd = _BaseInterstitialAd;

/// Implementing displaying MyTarget ads.
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

  Stream<AdEventMessage> get _adListenStream => _stream ??= channel
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
    try {
      final uid = await _channel.invokeMethod<String>(
        _methodCreateInterstitialAd,
        {'slotId': slotId},
      );

      assert(uid?.isNotEmpty ?? false);

      return InterstitialAd(this, uid!);
    } on Object catch (e, s) {
      return Error.throwWithStackTrace(FlutterError('Can not create Interstitial ad'), s);
    }
  }

  /// Create an Rewarded ads with [slotId]
  Future<RewardedAd> createRewardedAd(int slotId) async {
    try {
      final uid = await _channel.invokeMethod<String>(
        _methodCreateRewardedAd,
        {'slotId': slotId},
      );

      assert(uid?.isNotEmpty ?? false);

      return RewardedAd(this, uid!);
    } on Object catch (e, s) {
      return Error.throwWithStackTrace(FlutterError('Can not create Rewarded ad'), s);
    }
  }

  Future createBannerAd(int slotId) async {
    try {
      final uid = await _channel.invokeMethod<String>(
        _methodCreateBannerAd,
        {'slotId': slotId},
      );

      assert(uid?.isNotEmpty ?? false);
    } on Object catch (e, s) {
      return Error.throwWithStackTrace(FlutterError('Can not create Banner ad'), s);
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

/// Class for overlay advertisement like Rewarded Video & Interstitial
///
/// We using it cause myTargetSdk use similar logic under the hood
///
/// They're use BaseInterstitialAd class and extend it in
/// InterstitialAd and RewardedAd classes
///
class _BaseInterstitialAd {
  final MyTargetFlutter _plugin;
  final String uid;

  final _listeners = <AdStatusListener>{};

  _BaseInterstitialAd(this._plugin, this.uid) {
    _plugin._adListenStream.listen(_handleMessage);
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

/// Single banner advertisement
class BannerAd extends StatefulWidget {
  const BannerAd(this._plugin, this.uid, {Key? key, this.listener}) : super(key: key);
  final MyTargetFlutter _plugin;
  final int uid;
  final AdStatusListener? listener;

  @override
  State<BannerAd> createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAd> {
  final _listeners = <AdStatusListener>{};

  @override
  void initState() {
    super.initState();
    widget._plugin.createBannerAd(widget.uid);
    if (widget.listener != null) _listeners.add(widget.listener!);
    widget._plugin._adListenStream.listen(_handleMessage);
  }

  Future<void> _handleMessage(AdEventMessage data) async {
    if (data.uid == widget.uid.toString()) {
      _listeners.handleEvent(data);
    }
  }

  @override
  Widget build(BuildContext context) {
    const viewType = 'mytarget-banner-ad';

    final creationParams = <String, dynamic>{
      'id': widget.uid,
    };

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: viewType,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: viewType,
          creationParams: creationParams,
          creationParamsCodec: const StandardMessageCodec(),
        );
      default:
        throw UnsupportedError('Unsupported platform view');
    }
  }
}
