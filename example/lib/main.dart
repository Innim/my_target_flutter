import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_target_flutter/my_target_flutter.dart';
import 'package:my_target_flutter_example/tabs/banner_screen.dart';
import 'package:my_target_flutter_example/tabs/interstitial_screen.dart';
import 'package:my_target_flutter_example/tabs/rewarded_screen.dart';

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
