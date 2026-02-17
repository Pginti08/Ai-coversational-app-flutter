import 'dart:io';

import 'package:dio/dio.dart' as dio_pkg;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/try-on/controller/tryon_preview_controller.dart';

class TryOnPreviewScreen extends StatefulWidget {
  const TryOnPreviewScreen({super.key});

  @override
  State<TryOnPreviewScreen> createState() => _TryOnPreviewScreenState();
}

class _TryOnPreviewScreenState extends State<TryOnPreviewScreen>
    with SingleTickerProviderStateMixin {
  final controller = Get.put(TryOnPreviewController());
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<String> _downloadImageToTemp(String url, String filename) async {
    final tempDir = Directory.systemTemp;
    final filePath =
        '${tempDir.path}/$filename\_${DateTime.now().millisecondsSinceEpoch}.png';
    await dio_pkg.Dio().download(url, filePath);
    return filePath;
  }

  Future<void> _saveToGallery() async {
    try {
      // 1. Check/Request Permission
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      // 2. Download image bytes
      final imageUrl = controller.tryOnResult.value?.resultImageUrl;
      if (imageUrl == null) return;

      final response = await dio_pkg.Dio().get(
        imageUrl,
        options: dio_pkg.Options(responseType: dio_pkg.ResponseType.bytes),
      );

      // 3. Save to a temporary file
      final tempDir = Directory.systemTemp;
      final path =
          '${tempDir.path}/vousvous_tryon_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(path);
      await file.writeAsBytes(response.data);

      // 4. Use gal to put the file into the gallery
      await Gal.putImage(path);

      toast("Image saved successfully!", type: ToastType.success);

      // Clean up: delete the temp file
      if (await file.exists()) await file.delete();
    } catch (e) {
      debugPrint("Gal Save Error: $e");
      if (e is GalException) {
        toast("Permission denied or gallery error");
      } else {
        toast("Error saving image: $e");
      }
    }
  }

  Future<void> _shareTryOnImage() async {
    try {
      final imageUrl = controller.tryOnResult.value?.resultImageUrl;
      if (imageUrl == null) return;

      final filePath = await _downloadImageToTemp(imageUrl, 'tryon_share');

      final box = context.findRenderObject() as RenderBox?;
      final shareOrigin =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      await SharePlus.instance.share(
        ShareParams(
          text:
              '✨ Check out my virtual try-on from VOUSVOUS! 👗\n\nDownload VOUSVOUS now and try on outfits virtually!\n\n#VOUSVOUS #VirtualTryOn #FashionTech',
          subject: '✨ My Virtual Try-On - VOUSVOUS',
          files: [XFile(filePath)],
          sharePositionOrigin: shareOrigin,
        ),
      );
    } catch (e) {
      debugPrint("Error sharing: $e");
      toast("Failed to share image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isBottomEffect: false,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SafeArea(
              bottom: false,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Virtual Try-On",
                    style: style700S18,
                  ),
                  CommonContainer(
                    onTap: () => Get.back(),
                    child: SvgPicture.asset(
                      AssetConstants.closeIcon,
                      height: 30,
                    ),
                  ),
                ],
              ),
            ),
            hSizedBox16,
            Expanded(
              child: Obx(() {
                // Loading state
                if (controller.isLoading.value) {
                  return _buildLoadingState();
                }

                // Error state
                if (controller.errorMessage.value.isNotEmpty) {
                  return _buildErrorState();
                }

                // Success state
                if (controller.tryOnResult.value != null) {
                  return _buildSuccessState();
                }

                return const SizedBox.shrink();
              }),
            ),
            hSizedBox16,
            // Bottom action bar
            Obx(() {
              if (controller.tryOnResult.value != null &&
                  !controller.isLoading.value) {
                return SafeArea(
                  top: false,
                  child: _buildActionButtons(),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated shimmer container
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 200.w,
                height: 300.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.colorGradient[0].withAlpha(
                          (30 + 30 * _pulseController.value).toInt()),
                      AppColors.colorGradient[1].withAlpha(
                          (20 + 20 * _pulseController.value).toInt()),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.whiteColor.withAlpha(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AssetConstants.tryOn,
                      height: 48,
                      colorFilter: ColorFilter.mode(
                        AppColors.whiteColor.withAlpha(150),
                        BlendMode.srcIn,
                      ),
                    ),
                    hSizedBox20,
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.colorGradient[0],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          hSizedBox24,
          Text(
            "Generating your try-on...",
            style: style600S16.copyWith(color: AppColors.whiteTextColor),
          ),
          hSizedBox8,
          Text(
            "This may take a moment",
            style: style400S14.copyWith(color: AppColors.hintTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.redColor.withAlpha(20),
                border: Border.all(
                  color: AppColors.redColor.withAlpha(60),
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                color: AppColors.redColor,
                size: 40,
              ),
            ),
            hSizedBox20,
            Text(
              "Try-On Failed",
              style: style700S18,
            ),
            hSizedBox8,
            Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: style400S14.copyWith(color: AppColors.hintTextColor),
            ),
            hSizedBox30,
            AppButton(
              onTap: () => controller.generateTryOn(),
              text: "Try Again",
              height: 48,
              width: 160,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessState() {
    final imageUrl = controller.tryOnResult.value!.resultImageUrl!;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withAlpha(100),
          strokeAlign: BorderSide.strokeAlignOutside,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: AppNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          isOpenImageViewer: true,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              onTap: _shareTryOnImage,
              gradientBorderColors: AppColors.colorGradient,
              isOutlined: true,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AssetConstants.share,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.whiteColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  wSizedBox8,
                  Text("Share", style: style700S14),
                ],
              ),
            ),
          ),
          wSizedBox10,
          Expanded(
            child: AppButton(
              onTap: _saveToGallery,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AssetConstants.gallery,
                    height: 20,
                    colorFilter: const ColorFilter.mode(
                      AppColors.blackColor,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Save to Gallery',
                    style: style700S14.copyWith(color: AppColors.blackColor),
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
