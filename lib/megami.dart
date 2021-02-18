
import 'dart:async';

import 'package:flutter/services.dart';

class Megami {
  static const MethodChannel _channel =
      const MethodChannel('megami');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
