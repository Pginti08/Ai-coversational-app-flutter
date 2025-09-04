import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:toastification/toastification.dart';

enum ToastType {
  success,
  error,
  general,
}

toast(
  String message, {
  String? title,
  int seconds = 2,
  ToastType type = ToastType.error,
}) {
  if (isNotNullOrEmpty(message)) {
    toastification
      ..dismissAll()
      ..showCustom(
        alignment: Alignment.topCenter,
        direction: TextDirection.ltr,
        animationDuration: const Duration(milliseconds: 300),
        dismissDirection: DismissDirection.vertical,
        autoCloseDuration: Duration(seconds: seconds),
        builder: (context, holder) {
          return Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CommonContainer(
                enableBlur: true,
                backgroundColor: AppColors.blackColor.withAlpha(30),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                borderRadius: 20,
                borderColor: Color(0xFF2C2D2C),
                child: Row(
                  children: [
                    Container(
                      child: CommonContainer(
                        enableBlur: true,
                        backgroundColor: AppColors.blackColor.withAlpha(40),
                        borderRadius: 100,
                        padding: EdgeInsets.all(4),
                        child: SvgPicture.asset(
                          _getToastIcon(type),
                          width: 20,
                        ),
                      ),
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: _getToastColor(type),
                            blurRadius: 50,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                    ),
                    wSizedBox16,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title ?? _getTitle(type),
                                  overflow: TextOverflow.ellipsis,
                                  style: style400S16.copyWith(
                                    color: AppColors.textColor,
                                    letterSpacing: 0.32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          hSizedBox6,
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  message,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: style400S12.copyWith(
                                    color: AppColors.greyTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      );
  }
}

String _getToastIcon(ToastType type) {
  switch (type) {
    case ToastType.success:
      return AssetConstants.tickCircleGreen;
    case ToastType.general:
      return AssetConstants.notification;
    case ToastType.error:
      return AssetConstants.warning;
  }
}

Color _getToastColor(ToastType type) {
  switch (type) {
    case ToastType.success:
      return AppColors.greenColor;
    case ToastType.general:
      return AppColors.primaryColor;
    case ToastType.error:
      return AppColors.redColor;
  }
}

String _getTitle(ToastType type) {
  switch (type) {
    case ToastType.success:
      return "Success";
    case ToastType.general:
      return "General Notification";
    case ToastType.error:
      return "Error";
  }
}
