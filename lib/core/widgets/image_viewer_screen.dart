import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/common_container.dart';

class ImageViewerScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveToGallery() async {
    try {
      // Request permission
      // if (Platform.isAndroid) {
      //   final permission = await Permission.storage.request();
      //   if (!permission.isGranted) {
      //     toast("Storage permission required");
      //     return;
      //   }
      // } else if (Platform.isIOS) {
      //   final permission = await Permission.photos.request();
      //   if (!permission.isGranted) {
      //     toast("Photos permission required");
      //     return;
      //   }
      // }

      // Download image
      final imageUrl = fullImageUrl(widget.imageUrls[_currentIndex]);
      var response = await Dio().get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      // Save to gallery
      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: "vousvous_${DateTime.now().millisecondsSinceEpoch}",
      );

      if (result['isSuccess']) {
        toast("Image saved to gallery", type: ToastType.success);
      } else {
        toast("Failed to save image");
      }
    } catch (e) {
      toast("Error saving image: $e");
    }
  }

  void _goToNextImage() {
    if (_currentIndex < widget.imageUrls.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToPreviousImage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showNavigation = widget.imageUrls.length > 1;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Image PageView
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Center(
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(
                      fullImageUrl(widget.imageUrls[index])),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  heroAttributes: PhotoViewHeroAttributes(
                    tag: widget.imageUrls[index],
                  ),
                  loadingBuilder: (context, event) {
                    return RotatingLoader();
                  },
                ),
              );
            },
          ),
          // Close button at top right
          Positioned(
            top: 10,
            right: 10,
            child: SafeArea(
              bottom: false,
              child: CommonContainer(
                padding: const EdgeInsets.all(12),
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

          // Save to gallery button at bottom center
          Positioned(
            bottom: showNavigation ? 120 : 40,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Center(
                child: CommonContainer(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  borderRadius: 100,
                  borderGradientColors: AppColors.glassBorderGradient,
                  gradientColors: AppColors.glassBorderGradient,
                  onTap: _saveToGallery,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        AssetConstants.gallery,
                        height: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Save to Gallery',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Navigation arrows at bottom
          if (showNavigation)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left arrow
                    CommonContainer(
                      padding: const EdgeInsets.all(12),
                      isCircle: true,
                      borderGradientColors: AppColors.glassBorderGradient,
                      gradientColors: AppColors.glassBorderGradient,
                      onTap: _currentIndex > 0 ? _goToPreviousImage : null,
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: _currentIndex > 0
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Image counter
                    CommonContainer(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 12,
                      ),
                      borderRadius: 100,
                      borderGradientColors: AppColors.glassBorderGradient,
                      gradientColors: AppColors.glassBorderGradient,
                      child: Text(
                        '${_currentIndex + 1}/${widget.imageUrls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 24),

                    // Right arrow
                    CommonContainer(
                      padding: const EdgeInsets.all(12),
                      isCircle: true,
                      borderGradientColors: AppColors.glassBorderGradient,
                      gradientColors: AppColors.glassBorderGradient,
                      onTap: _currentIndex < widget.imageUrls.length - 1
                          ? _goToNextImage
                          : null,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: _currentIndex < widget.imageUrls.length - 1
                            ? Colors.white
                            : Colors.white.withOpacity(0.3),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
