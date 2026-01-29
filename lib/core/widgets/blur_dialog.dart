import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:vousvous/core/services/performance_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';

class BlurDialog {
  // Alternative method with more explicit sizing control
  Future<T?> show<T>({
    required Widget child,
    double blurAmount = 10,
    VoidCallback? onTapOutside,
    Color? overlayColor,
    double borderRadius = 24,
    List<Color>? gradientBorder,
    Color? backgroundColor,
    EdgeInsets? contentPadding,
    EdgeInsets? screenMargin,
    double maxWidthFraction = 1.0, // Full width minus margins
    double maxHeightFraction = 0.8, // Fraction of screen height
    double? minWidth,
    double? minHeight,
    bool barrierDismissible = true, // Set to false for force dialogs
  }) {
    return Get.dialog(
      GestureDetector(
        onTap: barrierDismissible
            ? (onTapOutside ?? () => Get.back())
            : null, // Disable tap outside for force dialogs
        child: Material(
          color: Colors.transparent,
          child: BackdropFilter(
            filter: PerformanceService.instance.getScaledBlurFilter(blurAmount),
            child: Container(
              width: double.infinity,
              height: double.infinity,
              padding: screenMargin ??
                  const EdgeInsets.symmetric(
                    horizontal: 12.0, // Changed from 24.0 to 12.0
                    vertical: 40.0,
                  ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Get.width * maxWidthFraction,
                    maxHeight: Get.height * maxHeightFraction,
                    minWidth: minWidth ?? 0,
                    minHeight: minHeight ?? 0,
                  ),
                  child: IntrinsicHeight(
                    child: GestureDetector(
                      onTap:
                          () {}, // Prevent tap from propagating to background
                      child: Container(
                        width: double.infinity,
                        padding: contentPadding ??
                            EdgeInsets.symmetric(
                              horizontal: 15.w,
                              vertical: 20.h,
                            ),
                        decoration: BoxDecoration(
                          color: backgroundColor ??
                              AppColors.blackColor.withAlpha(200),
                          borderRadius: BorderRadius.circular(borderRadius),
                          border: GradientBoxBorder(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: gradientBorder ??
                                  AppColors.glassBorderGradient,
                            ),
                            width: 1,
                          ),
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      barrierColor: overlayColor ?? AppColors.blackColor.withAlpha(150),
      barrierDismissible: barrierDismissible,
    );
  }
}
