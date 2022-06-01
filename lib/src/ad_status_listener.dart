import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

typedef AdEventCallback = void Function(Map<String, dynamic>?);

class AdStatusListener {
  static const _listenChannelName = 'my_target_flutter/ad_listener';

  static const _adLoaded = 'ad_loaded';
  static const _noAd = 'no_ad';
  static const _clickOnAd = 'click_on_ad';
  static const _adDisplay = 'ad_display';
  static const _adDismiss = 'ad_dismiss';
  static const _adVideoCompleted = 'ad_video_completed';

  final String adUid;
  final VoidCallback? onAdLoaded;

  final AdEventCallback? onNoAd;

  final VoidCallback? onClickOnAD;

  final VoidCallback? onDisplay;

  final VoidCallback? onDismiss;

  final VoidCallback? onVideoCompleted;

  AdStatusListener(this.adUid,
      {this.onAdLoaded,
      this.onNoAd,
      this.onDisplay,
      this.onDismiss,
      this.onClickOnAD,
      this.onVideoCompleted}) {
    const channel = EventChannel(_listenChannelName);
    channel.receiveBroadcastStream().listen(_handleMassage);
  }

  Future<void> _handleMassage(dynamic data) async {
    final message = _AdEventMessage.fromJson(Map<String, dynamic>.from(data));
    if (message.uid != null && message.event != null && message.uid == adUid) {
      switch (message.event) {
        case _adLoaded:
          onAdLoaded?.call();
          break;
        case _noAd:
          onNoAd?.call(message.data);
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
}

class _AdEventMessage {
  final String? uid;
  final String? event;
  final Map<String, dynamic>? data;

  const _AdEventMessage(this.uid, this.event, this.data);

  factory _AdEventMessage.fromJson(Map<String, dynamic> map) => _AdEventMessage(
      map['uid'] as String?,
      map['event'] as String?,
      (map['data'] as Map<dynamic, dynamic>?)?.cast<String, dynamic>());

  @override
  String toString() {
    return '_AdEventMessage{uid: $uid, event: $event, data: $data}';
  }
}
