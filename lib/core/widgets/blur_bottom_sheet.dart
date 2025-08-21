import 'dart:ui';

import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

enum BottomSheetHeightType { fixed, maxHeight }

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
    BottomSheetHeightType heightType = BottomSheetHeightType.fixed,
    double? height, // Used for fixed height or max height
  }) async {
    // Unfocus keyboard first
    FocusManager.instance.primaryFocus?.unfocus();

    // Wait 300 milliseconds
    await Future.delayed(const Duration(milliseconds: 300));

    return Get.bottomSheet<T>(
      PopScope(
        canPop: false, // Prevent default pop behavior
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) {
            handleClose(context, onClose);
          }
        },
        child: Stack(
          children: [
            // This makes the blurred background area tappable.
            GestureDetector(
              onTap: () => handleClose(context, onClose),
              child: RepaintBoundary(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: blurStrength,
                    sigmaY: blurStrength,
                  ),
                  // The container with a color is necessary for the GestureDetector to register hits.
                  child: Container(color: Colors.transparent),
                ),
              ),
            ),

            // Main sheet content with proper safe area
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: GestureDetector(
                  onTap: () {
                    // This onTap for the content area prevents the tap from
                    // falling through to the background GestureDetector.
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isCloseButton) ...[
                        _buildCloseButton(context, onClose, backgroundColor),
                        const SizedBox(height: 24),
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
                                child: SafeArea(
                                  top: false,
                                  child: _buildChildWithHeightConstraints(
                                    child: child,
                                    heightType: heightType,
                                    height: height ??
                                        MediaQuery.sizeOf(context).height * 0.5,
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
      isDismissible: false,
      barrierColor: barrierColor ?? Colors.black.withAlpha(150),
      enableDrag: enableDrag,
      // CORRECTED: Always true to ensure the gesture detector for the background works.
      isScrollControlled: true,
      ignoreSafeArea: !useSafeArea,
      backgroundColor: Colors.transparent,
    );
  }

  static Widget _buildChildWithHeightConstraints({
    required Widget child,
    required BottomSheetHeightType heightType,
    required double height,
  }) {
    switch (heightType) {
      case BottomSheetHeightType.fixed:
        return SizedBox(height: height, child: child);

      case BottomSheetHeightType.maxHeight:
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: height),
          child: child,
        );
    }
  }

  Widget _buildCloseButton(
      BuildContext context, VoidCallback? onClose, Color? backgroundColor) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: () {
        handleClose(context, onClose);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          gradient: backgroundColor == null
              ? LinearGradient(colors: AppColors.glassGradient)
              : null,
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

  void handleClose(
    BuildContext context,
    VoidCallback? onClose,
  ) {
    if (onClose != null) {
      onClose.call();
    } else {
      FocusManager.instance.primaryFocus?.unfocus();
      if (Get.isBottomSheetOpen ?? false) {
        Get.back();
      }
    }
  }
}
