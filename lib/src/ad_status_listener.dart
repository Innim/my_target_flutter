import 'package:flutter/cupertino.dart';

typedef AdEventCallback = void Function(Map<String, dynamic>?);

class AdStatusListener {
  static const _adLoaded = 'ad_loaded';
  static const _noAd = 'no_ad';
  static const _clickOnAd = 'click_on_ad';
  static const _adDisplay = 'ad_display';
  static const _adShow = 'ad_show';
  static const _adReward = 'ad_reward';
  static const _adDismiss = 'ad_dismiss';
  static const _adVideoCompleted = 'ad_video_completed';

  final VoidCallback? onAdLoaded;
  final AdEventCallback? onNoAd;
  final VoidCallback? onClickOnAD;
  final VoidCallback? onDisplay;
  final VoidCallback? onShow;
  final VoidCallback? onReward;
  final VoidCallback? onDismiss;
  final VoidCallback? onVideoCompleted;

  AdStatusListener._(
      {this.onAdLoaded,
      this.onShow,
      this.onReward,
      this.onNoAd,
      this.onDisplay,
      this.onDismiss,
      this.onClickOnAD,
      this.onVideoCompleted});

  factory AdStatusListener.banner(
          {VoidCallback? onAdLoaded,
          VoidCallback? onShow,
          AdEventCallback? onNoAd,
          VoidCallback? onClickOnAD}) =>
      AdStatusListener._(
          onAdLoaded: onAdLoaded, onShow: onShow, onNoAd: onNoAd, onClickOnAD: onClickOnAD);

  factory AdStatusListener.interstitial({
    VoidCallback? onAdLoaded,
    VoidCallback? onDismiss,
    VoidCallback? onDisplay,
    VoidCallback? onVideoCompleted,
    AdEventCallback? onNoAd,
    VoidCallback? onClickOnAD,
  }) =>
      AdStatusListener._(
        onAdLoaded: onAdLoaded,
        onDisplay: onDisplay,
        onDismiss: onDismiss,
        onVideoCompleted: onVideoCompleted,
        onNoAd: onNoAd,
        onClickOnAD: onClickOnAD,
      );
  factory AdStatusListener.rewarded({
    VoidCallback? onAdLoaded,
    VoidCallback? onDismiss,
    VoidCallback? onDisplay,
    VoidCallback? onReward,
    AdEventCallback? onNoAd,
    VoidCallback? onClickOnAD,
  }) =>
      AdStatusListener._(
        onAdLoaded: onAdLoaded,
        onDisplay: onDisplay,
        onDismiss: onDismiss,
        onReward: onReward,
        onNoAd: onNoAd,
        onClickOnAD: onClickOnAD,
      );

  void handleEvent(AdEventMessage data) async {
    switch (data.event) {
      case _adShow:
        onShow?.call();
        break;
      case _adReward:
        onReward?.call();
        break;
      case _adLoaded:
        onAdLoaded?.call();
        break;
      case _noAd:
        onNoAd?.call(data.data);
        break;
      case _clickOnAd:
        onClickOnAD?.call();
        break;
      case _adDisplay:
        onDisplay?.call();
        break;
      case _adDismiss:
        onDismiss?.call();
        break;
      case _adVideoCompleted:
        onVideoCompleted?.call();
    }
  }
}

class AdEventMessage {
  final String uid;
  final String event;
  final Map<String, dynamic>? data;

  const AdEventMessage(this.uid, this.event, this.data);

  factory AdEventMessage.fromJson(Map<String, dynamic> map) => AdEventMessage(map['uid'] as String,
      map['event'] as String, (map['data'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>());

  @override
  String toString() {
    return 'AdEventMessage{uid: $uid, event: $event, data: $data}';
  }
}
