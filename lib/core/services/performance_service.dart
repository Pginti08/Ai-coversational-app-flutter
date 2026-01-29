import 'dart:io';
import 'dart:ui';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Enum representing device performance tiers
enum PerformanceTier {
  low, // Low-end devices - minimal effects
  medium, // Mid-range devices - reduced effects
  high, // High-end devices - full effects
}

/// Service to detect device capability and provide optimized blur/effect values
class PerformanceService extends GetxService {
  static PerformanceService get instance => Get.find<PerformanceService>();

  final Rx<PerformanceTier> _tier = PerformanceTier.medium.obs;
  PerformanceTier get tier => _tier.value;

  // Cached values for quick access
  double _blurStrength = 10.0;
  double _animationDuration = 300.0;

  /// Initialize the service - call this early in app startup
  Future<PerformanceService> init() async {
    await _detectDevicePerformance();

    return this;
  }

  /// Detect device performance based on hardware specs
  Future<void> _detectDevicePerformance() async {
    try {
      final deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        _evaluateAndroidDevice(androidInfo);
      } else if (Platform.isIOS) {
        // iOS devices are always considered high performance
        _tier.value = PerformanceTier.high;
        debugPrint('📱 iOS Device - Setting to high performance tier');
      }

      debugPrint('📱 Performance Tier: ${_tier.value}');
    } catch (e) {
      debugPrint('⚠️ Failed to detect device performance: $e');
      // Default to medium tier on error
      _tier.value = PerformanceTier.medium;
    }
  }

  /// Evaluate Android device performance
  void _evaluateAndroidDevice(AndroidDeviceInfo info) {
    // Check SDK version (older devices tend to be slower)
    final sdkInt = info.version.sdkInt;

    // Get physical device info
    final isPhysicalDevice = info.isPhysicalDevice;
    final model = info.model.toLowerCase();
    final brand = info.brand.toLowerCase();

    // Score-based evaluation
    int score = 0;

    // SDK version scoring
    if (sdkInt >= 33) {
      score += 3; // Android 13+
    } else if (sdkInt >= 30) {
      score += 2; // Android 11-12
    } else if (sdkInt >= 28) {
      score += 1; // Android 9-10
    }
    // Below Android 9 = 0 points (old device)

    // Brand/flagship detection
    final flagshipBrands = [
      'samsung',
      'google',
      'oneplus',
      'xiaomi',
      'oppo',
      'vivo',
      'huawei',
      'sony'
    ];
    final budgetIndicators = [
      'go',
      'lite',
      'neo',
      'play',
      'a0',
      'a1',
      'a2',
      'j',
      'm0',
      'm1',
      'm2'
    ];

    if (flagshipBrands.any((b) => brand.contains(b))) {
      score += 1;
    }

    // Check for budget model indicators
    if (budgetIndicators.any((b) => model.contains(b))) {
      score -= 1;
    }

    // Check for flagship model indicators
    final flagshipModels = ['ultra', 'pro', 'plus', 'max', 'pixel'];
    if (flagshipModels.any((m) => model.contains(m))) {
      score += 1;
    }

    // Emulator detection (usually has good performance)
    if (!isPhysicalDevice) {
      score += 2;
    }

    // Determine tier based on score
    if (score >= 4) {
      _tier.value = PerformanceTier.high;
    } else if (score >= 2) {
      _tier.value = PerformanceTier.medium;
    } else {
      _tier.value = PerformanceTier.low;
    }

    debugPrint('📱 Android Device: ${info.brand} ${info.model}');
    debugPrint('📱 SDK Version: $sdkInt, Score: $score');
  }

  // ==================== PUBLIC API ====================

  /// Get optimized blur strength based on device capability
  double get blurStrength => _blurStrength;

  /// Get optimized animation duration
  Duration get animationDuration =>
      Duration(milliseconds: _animationDuration.toInt());

  /// Check if device is low-end
  bool get isLowEnd => _tier.value == PerformanceTier.low;

  /// Check if device is high-end
  bool get isHighEnd => _tier.value == PerformanceTier.high;

  /// Get blur filter based on device capability
  ImageFilter get optimalBlurFilter {
    return ImageFilter.blur(sigmaX: _blurStrength, sigmaY: _blurStrength);
  }

  /// Get blur filter with custom max strength
  /// Will be scaled down based on device capability
  ImageFilter getScaledBlurFilter(double maxStrength) {
    double scaledStrength;
    switch (_tier.value) {
      case PerformanceTier.high:
        scaledStrength = maxStrength;
        break;
      case PerformanceTier.medium:
        scaledStrength = maxStrength * 0.6;
        break;
      case PerformanceTier.low:
        scaledStrength = maxStrength * 0.3;
        break;
    }

    return ImageFilter.blur(sigmaX: scaledStrength, sigmaY: scaledStrength);
  }
}
