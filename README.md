# my_target_flutter

Flutter plugin to use MyTarget Interstitial ads.

## SDK version

MyTarget SDK version, used in plugin:

* iOS: **^5.15.2** ([GitHub](https://github.com/myTargetSDK/mytarget-ios/)
* Android: **^5.15.2** ([Maven](https://search.maven.org/search?q=a:mytarget-sdk))

## Minimum requirements

* iOS **9.0** and higher.
* Android **4.0** and newer (SDK **14**).

## Getting Started

1. add `my_target_flutter` as a [dependency in your pubspec.yaml file](https://docs.flutter.dev/development/packages-and-plugins/using-packages);
2. create an instance of MyTargetFlutter and initialise MyTargetSdk:
```dart
import 'package:my_target_flutter/my_target_flutter.dart';

final _plugin = MyTargetFlutter(isDebug: isDebug);
await _plugin.initialize();
```
3. create an instance of InterstitialAd and an instanse of AdStatusListener:

```dart
 late InterstitialAd _interstitialAd;

 _interstitialAd = await _plugin.createInterstitialAd(yourSlotId);
final adListener = AdStatusListener(interstitialAd.uid,
    onAdLoaded:  _onloaded,
    onDisplay:  _onDisplay,
    onClickOnAD: _onClickOnAD,
    onVideoCompleted: _onVideoCompleted,
    onDismiss:  _onDismiss,
    onNoAd: _onNoAd);

```
4. show ads when it is loaded:
```dart
void _onloaded()  {
  _interstitialAd.show();
}
```
See [MyTarget documentation](https://target.my.com/help/partners/mob/en) for full information.
