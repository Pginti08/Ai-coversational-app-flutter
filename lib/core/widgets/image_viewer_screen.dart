import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/widgets/app_loader.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerScreen extends StatelessWidget {
  final String imageUrl;

  const ImageViewerScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              minScale: PhotoViewComputedScale.contained,
              maxScale: PhotoViewComputedScale.covered * 2,
              heroAttributes: PhotoViewHeroAttributes(tag: imageUrl),
              loadingBuilder: (context, event) {
                return RotatingLoader();
              },
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: SafeArea(
              bottom: false,
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: CommonContainer(
                  padding: EdgeInsets.all(12),
                  isCircle: true,
                  borderGradientColors: AppColors.glassBorderGradient,
                  gradientColors: AppColors.glassBorderGradient,
                  onTap: () {
                    Get.back();
                  },
                  child: SvgPicture.asset(AssetConstants.closeIcon),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
