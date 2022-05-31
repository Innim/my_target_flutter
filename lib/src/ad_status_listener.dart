import 'package:flutter/services.dart';

abstract class AdStatusListener {
  const AdStatusListener();

  static const _listenChannelName = 'my_target_flutter/ad_listener';

  static const _adLoaded = 'ad_loaded';
  static const _noAd = 'no_ad';
  static const _clickOnAd = 'click_on_ad';
  static const _adDisplay = 'ad_display';
  static const _adDismiss = 'ad_dismiss';
  static const _adVideoCompleted = 'ad_video_completed';

  void listen() {
    const channel =
        BasicMessageChannel<String>(_listenChannelName, StringCodec());

    channel.setMessageHandler((message) => _handleMassage(message));
  }

  void onAdLoaded();

  void onNoAd();

  void onClickOnAD();

  void onDisplay();

  void onDismiss();

  void onVideoCompleted();

  Future<String> _handleMassage(String? massage) async {
    switch (massage) {
      case _adLoaded:
        onAdLoaded();
        break;
      case _noAd:
        onNoAd();
        break;
      case _clickOnAd:
        onClickOnAD();
        break;
      case _adDisplay:
        onDisplay();
        break;
      case _adDismiss:
        onDismiss();
        break;
      case _adVideoCompleted:
        onVideoCompleted();
    }
    return 'message is handled';
  }
}
