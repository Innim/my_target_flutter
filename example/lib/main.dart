import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_target_flutter/my_target_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  final plugin = MyTargetFlutter(isDebug: true);

  MyApp({
    Key? key,
  }) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late AdStatusListener adListener;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    adListener = AdListener(widget.plugin);
    adListener.listen();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      await widget.plugin.initialise(6896, true);
    } on PlatformException {
      log('inititalisation failed');
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;
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
                child: const Text('load AD'),
                onTap: widget.plugin.load,
              ),
              const SizedBox(height: 50),
              InkWell(
                child: const Text('show AD'),
                onTap: widget.plugin.show,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdListener extends AdStatusListener {
  final MyTargetFlutter plugin;
  const AdListener(this.plugin);
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
