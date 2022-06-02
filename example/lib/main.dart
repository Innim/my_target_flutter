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

class _MyAppState extends State<MyApp> {
  final _plugin = MyTargetFlutter(isDebug: true);
  InterstitialAd? _ad;
  var _adStatus = 'not created';

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
        body: Center(
          child: Builder(builder: (context) {
            return Column(
              children: [
                const SizedBox(height: 50),
                InkWell(
                    child: const Text('Create AD'),
                    onTap: () async {
                      _ad?.clearListeners();

                      final ad = _ad = await _plugin.createInterstitialAd(6896);
                      final adListener = AdStatusListener(
                          onAdLoaded: () => _changeAdStatus('Ad loaded'),
                          onDisplay: () => _changeAdStatus('Ad display'),
                          onClickOnAD: () => _changeAdStatus('Clicked on ad'),
                          onVideoCompleted: () =>
                              _changeAdStatus('Ad video completed'),
                          onDismiss: () => _changeAdStatus('Ad closed'),
                          onNoAd: (reason) =>
                              _changeAdStatus('Ad not loaded: $reason'));
                      ad.addListener(adListener);
                      _changeAdStatus('Ad created');
                    }),
                const SizedBox(height: 50),
                InkWell(
                  child: const Text('Load AD'),
                  onTap: () async {
                    if (_ad == null) {
                      _showError(context, 'Ad not created');
                    } else {
                      _ad!.load();
                    }
                  },
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
        ),
      ),
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

  void _changeAdStatus(String status) {
    setState(() {
      _adStatus = status;
    });
  }
}
