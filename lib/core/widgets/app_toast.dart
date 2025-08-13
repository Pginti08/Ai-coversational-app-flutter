import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';

toast(String message, {int seconds = 2, bool isSuccess = false}) {
  if (isNotNullOrEmpty(message)) {
    toastification
      ..dismissAll()
      ..show(
        type:
            !isSuccess ? ToastificationType.error : ToastificationType.success,
        style: ToastificationStyle.minimal,
        autoCloseDuration: const Duration(seconds: 2),
        description: Text(
          message,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: style500S14,
        ),
        alignment: Alignment.topCenter,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        icon: Icon(!isSuccess ? Icons.error : Icons.done, size: 20),
        backgroundColor: AppColors.scaffoldColor,
        showIcon: true,
        borderSide: const BorderSide(color: AppColors.greyBorderColor),
        foregroundColor: AppColors.whiteColor,
        progressBarTheme: const ProgressIndicatorThemeData(
          color: AppColors.primaryColor,
          linearMinHeight: 1,
        ),
        primaryColor: AppColors.primaryColor,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
        borderRadius: BorderRadius.circular(12),
        showProgressBar: true,
        closeOnClick: false,
        pauseOnHover: true,
        dragToClose: true,
        applyBlurEffect: true,
        closeButtonShowType: CloseButtonShowType.none,
        dismissDirection: DismissDirection.vertical,
      );
  }
}
