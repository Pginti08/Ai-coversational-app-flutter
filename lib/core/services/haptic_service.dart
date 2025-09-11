import 'dart:io' show Platform;

import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class HapticService {
  /// Light tap feedback
  static Future<void> light() async {
    if (Platform.isIOS) {
      HapticFeedback.lightImpact();
    } else {
      _androidVibrate(duration: 20, amplitude: 50);
    }
  }

  /// Medium tap feedback
  static Future<void> medium() async {
    if (Platform.isIOS) {
      HapticService.medium();
    } else {
      _androidVibrate(duration: 30, amplitude: 100);
    }
  }

  /// Heavy tap feedback
  static Future<void> heavy() async {
    if (Platform.isIOS) {
      HapticFeedback.heavyImpact();
    } else {
      _androidVibrate(duration: 40, amplitude: 200);
    }
  }

  /// Selection click feedback
  static Future<void> selection() async {
    if (Platform.isIOS) {
      HapticFeedback.selectionClick();
    } else {
      _androidVibrate(duration: 20, amplitude: 80);
    }
  }

  /// Fallback vibrate
  static Future<void> vibrate() async {
    HapticFeedback.vibrate();
  }

  /// Internal: Android vibration with control
  static Future<void> _androidVibrate(
      {int duration = 30, int amplitude = -1}) async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: duration, amplitude: amplitude);
    }
  }
}
