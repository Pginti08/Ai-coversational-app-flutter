import 'dart:ui';

import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

enum BottomSheetHeightType { auto, fixed, maxHeight }

class BlurBottomSheet {
  Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    VoidCallback? onClose,
    double borderRadius = 24,
    bool enableDrag = true,
    bool useSafeArea = true,
    Color? backgroundColor,
    Color? borderColor,
    Color? barrierColor,
    double blurStrength = 20,
    double backgroundBlurStrength = 0,
    bool isCloseButton = false,
    // Height configuration
    BottomSheetHeightType heightType = BottomSheetHeightType.auto,
    double? height, // Used for fixed height or max height
  }) {
    return Get.bottomSheet<T>(
      PopScope(
        canPop: false, // Prevent default pop behavior
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            handleClose(context);
          }
        },
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            handleClose(context);
          },
          child: Stack(
            children: [
              // Blur background (dismissable on tap)
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: blurStrength,
                  sigmaY: blurStrength,
                ),
                child: Container(color: Colors.transparent),
              ),
              // Main sheet content with proper safe area
              SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    onTap: () {
                      handleClose(context);
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (isCloseButton) ...[
                          _buildCloseButton(context),
                          SizedBox(height: 24),
                        ],
                        Flexible(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(borderRadius),
                            ),
                            child: RepaintBoundary(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(
                                  sigmaX: backgroundBlurStrength,
                                  sigmaY: backgroundBlurStrength,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: MediaQuery.of(
                                      context,
                                    ).viewInsets.bottom,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: backgroundColor ??
                                          AppColors.greyColor.withAlpha(220),
                                      border: Border(
                                        top: borderColor != null
                                            ? BorderSide(color: borderColor)
                                            : BorderSide.none,
                                      ),
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(borderRadius),
                                      ),
                                    ),
                                    child: _buildChildWithHeightConstraints(
                                      child: child,
                                      heightType: heightType,
                                      height: height,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isDismissible: false, // We handle dismissal manually
      barrierColor: barrierColor ?? Colors.black.withAlpha(150),
      enableDrag: enableDrag,
      isScrollControlled:
          heightType == BottomSheetHeightType.auto ? false : true,
      ignoreSafeArea: !useSafeArea,
      backgroundColor: Colors.transparent,
    );
  }

  static Widget _buildChildWithHeightConstraints({
    required Widget child,
    required BottomSheetHeightType heightType,
    double? height,
  }) {
    switch (heightType) {
      case BottomSheetHeightType.auto:
        return child;

      case BottomSheetHeightType.fixed:
        // Fixed height - set specific height
        assert(height != null, 'Height must be provided for fixed height type');
        return SizedBox(height: height!, child: child);

      case BottomSheetHeightType.maxHeight:
        // Max height - constrain to maximum height but allow auto sizing below that
        assert(height != null, 'Height must be provided for max height type');
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height!),
          child: child,
        );
    }
  }

  Widget _buildCloseButton(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        handleClose(context);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: AppColors.glassGradient),
          border: GradientBoxBorder(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: AppColors.glassBorderGradient,
            ),
          ),
        ),
        child: SvgPicture.asset(AssetConstants.closeIcon),
      ),
    );
  }

  void handleClose(BuildContext context) {
    // First dismiss keyboard
    FocusScope.of(context).unfocus();

    // Close the bottom sheet
    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
  }
}
