import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_target_flutter/my_target_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  final _plugin = MyTargetFlutter(isDebug: true);

  late final TabController tabController = TabController(vsync: this, length: 3);

  @override
  void initState() {
    super.initState();
    _initPlatformState();
  }

  Future<void> _initPlatformState() async {
    try {
      await _plugin.initialize();
    } on PlatformException {
      log('initialization failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: TabBarView(controller: tabController, children: [
          BannerScreen(_plugin),
          InterstitialScreen(_plugin),
          RewardedScreen(_plugin),
        ]),
        bottomNavigationBar: TabBar(controller: tabController, tabs: const [
          Tab(text: 'Banner'),
          Tab(text: 'Interstitial'),
          Tab(text: 'Rewarded'),
        ]),
      ),
    );
  }
}

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
            InkWell(child: const Text('Create AD'), onTap: () async => onTapInterstitial(context)),
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

class RewardedScreen extends StatefulWidget {
  const RewardedScreen(this._plugin, {Key? key}) : super(key: key);
  final MyTargetFlutter _plugin;

  @override
  State<RewardedScreen> createState() => _RewardedScreenState();
}

class _RewardedScreenState extends State<RewardedScreen> {
  RewardedAd? _ad;
  var _adStatus = 'not created';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Builder(builder: (context) {
        return Column(
          children: [
            const SizedBox(height: 50),
            InkWell(child: const Text('Create AD'), onTap: () async => onTapRewarded(context)),
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

  Future<void> onTapRewarded(BuildContext context) async {
    {
      _ad?.clearListeners();

      _ad = await widget._plugin.createRewardedAd(45101);
      final adListener = AdStatusListener.rewarded(
          onAdLoaded: () => _changeAdStatus('Ad loaded'),
          onDisplay: () => _changeAdStatus('Ad display'),
          onClickOnAD: () => _changeAdStatus('Clicked on ad'),
          onReward: () => _changeAdStatus('Ad video completed'),
          onDismiss: () => _changeAdStatus('Ad closed'),
          onNoAd: (reason) => _changeAdStatus('Ad not loaded: $reason'));
      _ad?.addListener(adListener);
      _changeAdStatus('Ad created');

      await Future.sync(() => _ad?.load());
      _ad?.show();
    }
  }

  void _changeAdStatus(String status) {
    setState(() {
      _adStatus = status;
    });
  }
}
