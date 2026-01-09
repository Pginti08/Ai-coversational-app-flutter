import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/widgets/image_viewer_screen.dart';
import 'package:vousvous/core/widgets/shimmer_utils.dart';

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
    this.isOpenImageViewer = false,
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
  final bool isOpenImageViewer;

  String get _fullImageUrl {
    if (imageUrl.isEmpty) return '';

    // Check if URL already has a protocol
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    // Otherwise, prepend the base URL
    return '${ApiConstants.imageURL}$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isOpenImageViewer
          ? () {
              Get.to(
                ImageViewerScreen(
                  imageUrls: [_fullImageUrl],
                ),
                opaque: false,
                transition: Transition.fadeIn,
                fullscreenDialog: true,
              );
            }
          : onTap,
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.zero,
        child: Container(
          width: width,
          height: height,
          clipBehavior: Clip.antiAlias,
          margin: padding,
          decoration: BoxDecoration(color: backgroundColor, shape: shape),
          child: isUrl(_fullImageUrl)
              ? Image.network(
                  _fullImageUrl,
                  fit: fit,
                  width: width,
                  height: height,
                  colorBlendMode: BlendMode.saturation,
                  color: imageColor,
                  filterQuality: filterQuality,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return shimmer(
                      child: shimmerContainer(
                        width: width ?? double.infinity,
                        height: height ?? 200,
                        borderRadius: 0,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: height ?? 200,
                    width: width ?? double.infinity,
                    color: AppColors.greyColor,
                    child: errorWidget ??
                        Center(
                          child: Icon(
                            Icons.error,
                            color: AppColors.hintTextColor,
                          ),
                        ),
                  ),
                )
              : errorWidget ??
                  Container(
                    height: height ?? 200,
                    width: width ?? double.infinity,
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
