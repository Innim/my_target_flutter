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
          child: Column(
            children: [
              const SizedBox(height: 50),
              InkWell(
                child: const Text('Create AD'),
                onTap: () async {
                  _ad?.clearListeners();

                  final ad = _ad = await _plugin.createInterstitialAd(6896);
                  ad.addListener(AdListener());
                },
              ),
              const SizedBox(height: 50),
              InkWell(
                child: const Text('Load AD'),
                onTap: () async {
                  if (_ad == null) {
                    _showError('Ad not created');
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
                    _showError('Ad not created');
                  } else {
                    _ad!.show();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showError(String text) {
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
}

class AdListener extends AdStatusListener {
  AdListener();

  @override
  void onAdLoaded() {
    plugin.show();
  }

  @override
  void onClickOnAD() {
    // TODO: implement onClickOnAD
  }

  @override
  void onDismiss() {
    // TODO: implement onDismiss
  }

  @override
  void onDisplay() {
    // TODO: implement onDisplay
  }

  @override
  void onNoAd() {
    // TODO: implement onNoAd
  }

  @override
  void onVideoCompleted() {
    // TODO: implement onVideoCompleted
  }
}
