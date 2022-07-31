import 'package:flutter/material.dart';
import 'package:my_target_flutter/my_target_flutter.dart';

class BannerScreen extends StatefulWidget {
  const BannerScreen(this._plugin, {Key? key}) : super(key: key);
  final MyTargetFlutter _plugin;

  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {
  BannerAd? _ad;
  var _adStatus = 'not created';
  late final AdStatusListener listener = AdStatusListener.banner(
      onAdLoaded: () => _changeAdStatus('Ad loaded'),
      onClickOnAD: () => _changeAdStatus('Clicked on ad'),
      onNoAd: (reason) => _changeAdStatus('Ad not loaded: $reason'));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Builder(builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 50),
            InkWell(child: const Text('Create AD'), onTap: () async => onTapRewarded(context)
                //  onTapInterstitial(context),
                ),
            const SizedBox(height: 50),
            InkWell(
              child: const Text('Load AD'),
              onTap: () async {},
            ),
            const SizedBox(height: 50),
            // InkWell(
            //   child: const Text('Show AD'),
            //   onTap: () async {
            //     if (_ad == null) {
            //       _showError(context, 'Ad not created');
            //     } else {
            //       _ad!.show();
            //     }
            //   },
            // ),
            SizedBox(height: 50, child: BannerAd(widget._plugin, '794557')),
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

  Future<void> onTapRewarded(BuildContext context) async {
    {
      _ad = await widget._plugin.createBannerAd(45101);
      // final adListener = AdStatusListener(
      //     onAdLoaded: () => _changeAdStatus('Ad loaded'),
      //     onDisplay: () => _changeAdStatus('Ad display'),
      //     onClickOnAD: () => _changeAdStatus('Clicked on ad'),
      //     onVideoCompleted: () => _changeAdStatus('Ad video completed'),
      //     onDismiss: () => _changeAdStatus('Ad closed'),
      //     onNoAd: (reason) => _changeAdStatus('Ad not loaded: $reason'));
      // _ad?.addListener(adListener);
      // _changeAdStatus('Ad created');

      // await Future.sync(() => _ad?.load());
      // _ad?.show();
    }
  }

  void _changeAdStatus(String status) {
    setState(() {
      _adStatus = status;
    });
  }
}
