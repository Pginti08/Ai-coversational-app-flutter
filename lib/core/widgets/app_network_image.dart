import 'dart:io';

import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/widgets/shimmer_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.imageUrl,
    super.key,
    this.fit,
    this.height,
    this.width,
    this.backgroundColor,
    this.imageBorderColor,
    this.filterQuality = FilterQuality.low,
    this.shape = BoxShape.rectangle,
    this.indicatorSize = 25.0,
    this.indicatorStrokeWidth,
    this.showProgressIndicator,
    this.onTap,
    this.fadeInDuration,
    this.fadeOutDuration,
    this.placeholderFadeInDuration,
    this.margin,
    this.padding,
    this.borderRadius,
    this.imageColor,
    this.borderWidth,
    this.blendMode,
    this.errorWidget,
  });
  final String imageUrl;
  final BoxFit? fit;
  final Color? backgroundColor;
  final Color? imageColor;
  final Color? imageBorderColor;
  final FilterQuality filterQuality;
  final BoxShape shape;
  final BlendMode? blendMode;
  final double? height;
  final double? width;
  final double? borderWidth;
  final double? indicatorSize;
  final double? indicatorStrokeWidth;
  final bool? showProgressIndicator;
  final Duration? fadeInDuration;
  final VoidCallback? onTap;
  final Duration? placeholderFadeInDuration;
  final Duration? fadeOutDuration;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Widget? errorWidget;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Container(
          height: height,
          width: width,
          clipBehavior: Clip.antiAlias,
          margin: padding,
          decoration: BoxDecoration(color: backgroundColor, shape: shape),
          child: isUrl(imageUrl)
              ? CachedNetworkImage(
                  imageBuilder: (context, imageProvider) => Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: imageProvider,
                        fit: fit,
                      ),
                    ),
                  ),
                  imageUrl: imageUrl,
                  fit: fit,
                  height: height,
                  width: width,
                  colorBlendMode: BlendMode.saturation,
                  color: imageColor,
                  // maxHeightDiskCache: 999,
                  // maxWidthDiskCache: 999,
                  // memCacheHeight: 999,
                  // memCacheWidth: 999,
                  filterQuality: filterQuality,
                  // fadeOutDuration:
                  //     fadeOutDuration ?? const Duration(microseconds: 1),
                  // placeholderFadeInDuration: placeholderFadeInDuration ??
                  //     const Duration(microseconds: 1),
                  // fadeInDuration:
                  //     fadeInDuration ?? const Duration(milliseconds: 500),
                  // progressIndicatorBuilder: (showProgressIndicator ?? false
                  //     ? (context, url, progress) => Center(
                  //           child: SizedBox(
                  //             height: indicatorSize,
                  //             width: indicatorSize,
                  //             child: Center(
                  //               child: CircularProgressIndicator(
                  //                   strokeWidth: indicatorStrokeWidth ?? 2.0,
                  //                   value: progress.progress),
                  //             ),
                  //           ),
                  //         )
                  //     : null),
                  placeholder: (context, url) => shimmer(
                    child: shimmerContainer(
                      width: width,
                      height: height,
                      borderRadius: 0,
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: height,
                    width: width,
                    color: AppColors.greyColor,
                    child: errorWidget ??
                        Center(
                          child: Icon(
                            Icons.error,
                            color: AppColors.hintTextColor,
                          ),
                        ),
                  ),
                  errorListener: (e) {
                    if (e is SocketException) {
                      print('Error with ${e.address} and message ${e.message}');
                    } else {
                      print('Image Exception is: ${e.runtimeType}');
                    }
                  },
                )
              : errorWidget ??
                  Container(
                    height: height,
                    width: width,
                    color: AppColors.greyColor,
                    child: Center(
                      child: Icon(
                        Icons.error,
                        color: AppColors.hintTextColor,
                      ),
                    ),
                  ),
        ),
      ),
    );
  }
}
