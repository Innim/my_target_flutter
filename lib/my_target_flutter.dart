
import 'dart:async';

import 'package:flutter/services.dart';

class MyTargetFlutter {
  static const MethodChannel _channel = MethodChannel('my_target_flutter');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
