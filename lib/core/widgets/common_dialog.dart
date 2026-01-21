import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/blur_dialog.dart';

void commonDialog({
  required String title,
  required String description,
  Widget? icon,
  required VoidCallback onSuccess,
  VoidCallback? onCancel,
  String successButtonTitle = "OK",
  String cancelButtonTitle = "Cancel",
  bool showCancel = true,
  bool isDismissible = true, // Set to false for force update dialogs
  RxBool? isLoading, // ← FIXED: do not assign default false.obs here
}) {
  final RxBool loading = isLoading ?? false.obs; // ← SAFELY handle null

  BlurDialog().show(
    barrierDismissible: isDismissible,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon,
          SizedBox(height: 10.h),
        ],

        /// Title
        Text(
          title,
          textAlign: TextAlign.center,
          style: style700S16.copyWith(color: AppColors.whiteColor),
        ),
        SizedBox(height: 20.h),

        /// Description
        Text(
          description,
          textAlign: TextAlign.center,
          style: style400S14.copyWith(color: AppColors.hintTextColor),
        ),
        SizedBox(height: 30.h),

        /// Buttons Row
        Row(
          children: [
            /// Cancel Button
            if (showCancel)
              Expanded(
                child: AppButton(
                  onTap: () {
                    Get.back();
                    onCancel?.call();
                  },
                  isOutlined: true,
                  text: cancelButtonTitle,
                  textColor: AppColors.whiteColor,
                ),
              ),

            if (showCancel) SizedBox(width: 10.w),

            /// Success Button
            Expanded(
              child: Obx(
                () => AppButton(
                  onTap: () {
                    if (!loading.value) {
                      onSuccess();
                    }
                  },
                  height: 44,
                  isLoading: loading.value, // SAFE
                  text: successButtonTitle,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
