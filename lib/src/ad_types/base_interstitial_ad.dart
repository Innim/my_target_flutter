import 'package:my_target_flutter/src/ad_status_listener.dart';
import 'package:my_target_flutter/src/extensions.dart';
import 'package:my_target_flutter/src/my_target_flutter.dart';

// Typedefs here for better user experience while using
// this package

typedef RewardedAd = _BaseInterstitialAd;
typedef InterstitialAd = _BaseInterstitialAd;

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
    _plugin.adListenStream.listen(_handleMessage);
  }

  Future<void> _handleMessage(AdEventMessage data) async {
    if (data.uid == uid) {
      _listeners.handleEvent(data);
    }
  }

  void load() {
    _plugin.load(uid);
  }

  void show() {
    _plugin.show(uid);
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
