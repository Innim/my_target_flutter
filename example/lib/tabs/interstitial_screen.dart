import 'package:flutter/material.dart';
import 'package:my_target_flutter/my_target_flutter.dart';

class InterstitialScreen extends StatefulWidget {
  const InterstitialScreen(this._plugin, {Key? key}) : super(key: key);
  final MyTargetFlutter _plugin;

  @override
  State<InterstitialScreen> createState() => _InterstitialScreenState();
}

class _InterstitialScreenState extends State<InterstitialScreen> {
  InterstitialAd? _ad;
  var _adStatus = 'not created';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Builder(builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 50),
            InkWell(child: const Text('Create AD'), onTap: () async => onTapInterstitial(context)
                //  onTapInterstitial(context),
                ),
            const SizedBox(height: 50),
            InkWell(
              child: const Text('Load AD'),
              onTap: () async {},
            ),
            const SizedBox(height: 50),
            InkWell(
              child: const Text('Show AD'),
              onTap: () async {
                if (_ad == null) {
                  _showError(context, 'Ad not created');
                } else {
                  _ad!.show();
                }
              },
            ),
            const SizedBox(height: 50),
            Text('Ad status: $_adStatus')
          ],
        );
      }),
    );
  }

  void _showError(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (builder) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(text),
        );
      },
    );
  }

  Future<void> onTapInterstitial(BuildContext context) async {
    {
      _ad?.clearListeners();

      final ad = _ad = await widget._plugin.createInterstitialAd(6896);
      final adListener = AdStatusListener.interstitial(
          onAdLoaded: () => _changeAdStatus('Ad loaded'),
          onDisplay: () => _changeAdStatus('Ad display'),
          onClickOnAD: () => _changeAdStatus('Clicked on ad'),
          onVideoCompleted: () => _changeAdStatus('Ad video completed'),
          onDismiss: () => _changeAdStatus('Ad closed'),
          onNoAd: (reason) => _changeAdStatus('Ad not loaded: $reason'));
      ad.addListener(adListener);
      _changeAdStatus('Ad created');
      if (_ad == null) {
        _showError(context, 'Ad not created');
      } else {
        await Future.sync(() => _ad!.load());
        _ad!.show();
      }
    }
  }

  void _changeAdStatus(String status) {
    setState(() {
      _adStatus = status;
    });
  }
}
