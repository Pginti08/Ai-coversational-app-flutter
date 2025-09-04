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
      baseColor: color?.withAlpha(200) ?? const Color(0xFF151515),
      highlightColor: color?.withAlpha(50) ?? const Color(0xFF262626),
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
