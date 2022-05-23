import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class AdStatusListener {
  final VoidCallback onAdLoaded;
  final VoidCallback onNoAd;
  final VoidCallback onClickOnAD;
  final VoidCallback onDisplay;
  final VoidCallback onDismiss;
  final VoidCallback onVideoCompleted;

  const AdStatusListener(
      {required this.onAdLoaded,
      required this.onClickOnAD,
      required this.onDismiss,
      required this.onDisplay,
      required this.onNoAd,
      required this.onVideoCompleted});

  static const _listenChannelName = 'my_target_flutter/ad_listener';

  static const _adLoaded = 'ad_loaded';
  static const _noAd = 'no_ad';
  static const _clicOnAd = 'click_on_ad';
  static const _adDisplay = 'ad_display';
  static const _adDisniss = 'ad_dismiss';
  static const _adVideoCompleted = 'ad_video_completed';

  void listen() {
    const channel =
        BasicMessageChannel<String>(_listenChannelName, StringCodec());

    channel.setMessageHandler((message) => _handleMassage(message));
  }

  Future<String> _handleMassage(String? massage) async {
    switch (massage) {
      case _adLoaded:
        onAdLoaded();
        break;
      case _noAd:
        onNoAd();
        break;
      case _clicOnAd:
        onClickOnAD();
        break;
      case _adDisplay:
        onDisplay();
        break;
      case _adDisniss:
        onDismiss();
        break;
      case _adVideoCompleted:
        onVideoCompleted();
    }
    return 'message is handled';
  }
}
