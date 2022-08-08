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
      onShow: () => _changeAdStatus('Ad shown'),
      onNoAd: (reason) => _changeAdStatus('Ad not loaded: $reason'));

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Builder(builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 50),
            const SizedBox(height: 50),
            SizedBox(
              height: 50,
              child: BannerAd(
                widget._plugin,
                794557,
                listener: listener,
              ),
            ),
            const SizedBox(height: 50),
            Text('Ad status: $_adStatus')
          ],
        );
      }),
    );
  }

  void _changeAdStatus(String status) {
    setState(() {
      _adStatus = status;
    });
  }
}
