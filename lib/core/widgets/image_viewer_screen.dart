import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
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

  String fullImageUrl(imageUrl) {
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
              child: GestureDetector(
                onTap: () {
                  Get.back();
                },
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
