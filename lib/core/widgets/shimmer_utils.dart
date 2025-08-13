import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget shimmer({
  required Widget child,
  Color? color,
  bool isShowSimmer = true,
}) {
  if (isShowSimmer == true) {
    return Shimmer.fromColors(
      baseColor: color?.withOpacity(0.8) ?? AppColors.greyColor,
      highlightColor:
          color?.withOpacity(0.2) ?? AppColors.greyColor.withOpacity(0.2),
      child: child,
    );
  } else {
    return child;
  }
}

Widget shimmerContainer({
  double? height,
  double? width,
  double? borderRadius,
  Widget? child,
  Decoration? decoration,
}) =>
    Container(
      height: height,
      width: width,
      decoration: decoration ??
          BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? 50),
            color: AppColors.greyColor,
          ),
    );
