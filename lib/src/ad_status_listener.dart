import 'dart:async';

import 'package:flutter/services.dart';

// TODO: переделать
abstract class AdStatusListener {
  static const _listenChannelName = 'my_target_flutter/ad_listener';

  static const _adLoaded = 'ad_loaded';
  static const _noAd = 'no_ad';
  static const _clickOnAd = 'click_on_ad';
  static const _adDisplay = 'ad_display';
  static const _adDismiss = 'ad_dismiss';
  static const _adVideoCompleted = 'ad_video_completed';

  AdStatusListener() {
    const channel = EventChannel(_listenChannelName);
    channel.receiveBroadcastStream().listen(_handleMassage);
  }

  void onAdLoaded();

  void onNoAd();

  void onClickOnAD();

  void onDisplay();

  void onDismiss();

  void onVideoCompleted();

  Future<void> _handleMassage(dynamic data) async {
    print('_handleMassage $data');
    // switch (massage) {
    //   case _adLoaded:
    //     onAdLoaded();
    //     break;
    //   case _noAd:
    //     onNoAd();
    //     break;
    //   case _clickOnAd:
    //     onClickOnAD();
    //     break;
    //   case _adDisplay:
    //     onDisplay();
    //     break;
    //   case _adDismiss:
    //     onDismiss();
    //     break;
    //   case _adVideoCompleted:
    //     onVideoCompleted();
    // }
    // return 'message is handled';
  }
}
