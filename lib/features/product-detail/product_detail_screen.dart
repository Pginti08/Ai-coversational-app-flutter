import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/extensions.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/product-detail/controller/product_detail_controller.dart';
import 'package:vousvous/features/try-on/utils/tryon_helper.dart';
import 'package:vousvous/routes/app_pages.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Define the min and max fractional sizes for the bottom sheet.
  final double _minSheetSize = 0.3;
  final double _maxSheetSize = 0.6;

  // A ValueNotifier to hold the current extent (fractional height) of the sheet.
  // This allows the background image to react to the sheet's movement.
  late final ValueNotifier<double> _sheetExtentNotifier;

  // Track the previous extent to determine drag direction
  double _previousExtent = 0.3;
  bool _isSheetClosing = false;

  final ProductDetailController controller = Get.put(ProductDetailController());

  @override
  void initState() {
    super.initState();
    // Initialize the notifier with the starting size.
    _sheetExtentNotifier = ValueNotifier(_minSheetSize);
    _previousExtent = _minSheetSize;
  }

  @override
  void dispose() {
    _sheetExtentNotifier.dispose();
    super.dispose();
  }

  // Method to download image and return file path
  Future<String?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final documentDirectory = await getTemporaryDirectory();
        final file = File('${documentDirectory.path}/shared_product_image.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }

  Future<void> _shareProduct() async {
    try {
      // 1. Setup Data
      final imageUrl = controller.productDetail.value.image ?? "";
      final productTitle = controller.productDetail.value.title ?? '-';
      final productId = controller.productDetail.value.id ?? '';
      final userName = controller.productDetail.value.username ?? '-';

      // 2. Create Link
      final String customLink =
          'https://vousvous.com/share?refferalCode=${LocalStorageService.instance.userInfo.value.data?.referralCode}&productId=$productId&imageUrl=$imageUrl';

      // 3. Create Message
      final String shareMessage = '''
✨ *${productTitle.toUpperCase()}* ✨

Check out this stunning outfit on *VOUSVOUS*! 👗✨

Designed by: $userName

🎨 Design your dream dress with intelligent styling
🔥 Discover unique fashion creations
💎 Connect with expert designers
🛍️ Get instant quotes effortlessly

Download *VOUSVOUS* now and bring your fashion vision to life!

👉 $customLink

#VOUSVOUS #DreamDress #IntelligentStyling #FashionDesign #StyleInspiration #OOTD
''';

      final String shareSubject =
          '✨ ${productTitle.toUpperCase()} - Fashion App';

      // 4. Prepare Files (if image exists)
      List<XFile> filesToShare = [];

      if (imageUrl.isNotEmpty) {
        final String? imagePath = await _downloadImage(imageUrl);
        if (imagePath != null && imagePath.isNotEmpty) {
          filesToShare.add(XFile(imagePath));
        }
      }

      // 5. Handle iPad Position (Optional but recommended)
      // iPad requires a source rect to anchor the share popup
      final box = context.findRenderObject() as RenderBox?;
      final Rect? shareOrigin =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      // 6. Execute Share using the NEW API
      // "Share.share" and "Share.shareXFiles" are replaced by "SharePlus.instance.share"
      // using a "ShareParams" object.
      await SharePlus.instance.share(
        ShareParams(
          text: shareMessage,
          subject: shareSubject,
          files: filesToShare, // Can be empty for text-only share
          sharePositionOrigin: shareOrigin, // Crucial for iPad
        ),
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
      toast('Error sharing: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Define the start and end heights for the background image animation.
    final initialImageHeight = screenHeight * 0.7;
    final finalImageHeight = screenHeight * 0.3;

    // Define the start and end widths for the background image animation.
    final initialImageWidth =
        screenWidth - 32; // Full width minus horizontal padding
    final finalImageWidth = screenWidth * 0.45; // 50% of screen width
    final initialBorderRadius = 24;
    final finalBorderRadius = 9;

    return Obx(() => Stack(
          children: [
            CustomScaffold(
              isBottomSafeArea: false,
              body: Stack(
                children: [
                  // --- Background Content ---
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: SvgPicture.asset(
                                AssetConstants.backward,
                                height: 26,
                              ),
                            ),
                            IconButton(
                              onPressed: _shareProduct,
                              icon: SvgPicture.asset(
                                AssetConstants.share,
                                height: 20,
                              ),
                            ),
                          ],
                        ),
                        hSizedBox6,
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: ValueListenableBuilder<double>(
                              valueListenable: _sheetExtentNotifier,
                              builder: (context, extent, child) {
                                final normalizedExtent =
                                    (extent - _minSheetSize) /
                                        (_maxSheetSize - _minSheetSize);
                                final clampedExtent =
                                    normalizedExtent.clamp(0.0, 1.0);

                                final imageHeight = lerpDouble(
                                    initialImageHeight,
                                    finalImageHeight,
                                    clampedExtent);

                                final imageWidth = lerpDouble(initialImageWidth,
                                    finalImageWidth, clampedExtent);
                                final imageBorderRadius = lerpDouble(
                                    initialBorderRadius,
                                    finalBorderRadius,
                                    clampedExtent);

                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      imageBorderRadius ?? 0),
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 10),
                                    curve: Curves.linear,
                                    height: imageHeight,
                                    width: imageWidth,
                                    child: child,
                                  ),
                                );
                              },
                              child: AppNetworkImage(
                                imageUrl:
                                    controller.productDetail.value.image ?? "",
                                fit: BoxFit.cover,
                                isOpenImageViewer: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // --- "Try On Me" Button (hides during drag) ---
                  Positioned(
                    top: 62,
                    right: 28,
                    child: ValueListenableBuilder<double>(
                      valueListenable: _sheetExtentNotifier,
                      builder: (context, extent, child) {
                        final normalizedExtent = (extent - _minSheetSize) /
                            (_maxSheetSize - _minSheetSize);
                        final opacity =
                            (1.0 - normalizedExtent * 3).clamp(0.0, 1.0);

                        return IgnorePointer(
                          ignoring: opacity == 0.0,
                          child: AnimatedOpacity(
                            duration: const Duration(milliseconds: 150),
                            opacity: opacity,
                            child: child!,
                          ),
                        );
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          AppButton(
                            onTap: () {
                              Get.toNamed(Routes.chat, arguments: {
                                "isInitialRemix": true,
                                "userSelectedRemixOutfits": [
                                  controller.productDetail.value.image ?? ""
                                ]
                              });
                            },
                            borderColor: AppColors.hintTextColor,
                            height: 34,
                            width: 34,
                            child: SvgPicture.asset(
                              AssetConstants.magicpen,
                              color: AppColors.blackColor.withAlpha(150),
                              width: 18,
                            ),
                          ),
                          // hSizedBox6,
                          AppButton(
                            onTap: () {
                              openTryOnFlow(
                                context: context,
                                productImageUrl:
                                    controller.productDetail.value.image ?? "",
                              );
                            },
                            text: "Try On Me",
                            borderColor: AppColors.hintTextColor,
                            textColor: AppColors.blackColor.withAlpha(200),
                            fontSize: 12,
                            height: 34,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // --- Draggable Bottom Sheet ---
                  NotificationListener<DraggableScrollableNotification>(
                    onNotification: (notification) {
                      // Determine if the sheet is closing (extent is decreasing)
                      _isSheetClosing = notification.extent < _previousExtent;
                      _previousExtent = notification.extent;

                      // Update the notifier with the new extent as the sheet is dragged.
                      _sheetExtentNotifier.value = notification.extent;
                      // Return true to allow the notification to continue bubbling up.
                      return true;
                    },
                    child: DraggableScrollableSheet(
                      initialChildSize: _minSheetSize,
                      minChildSize: _minSheetSize,
                      maxChildSize: _maxSheetSize,
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        // The content of the bottom sheet.
                        return ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          child: LiquidGlassLayer(
                            child: LiquidGlass(
                              shape:
                                  LiquidRoundedSuperellipse(borderRadius: 24),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(150),
                                  border: Border(
                                      top: BorderSide(
                                          color: AppColors.whiteColor
                                              .withAlpha(100))),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(24),
                                    topRight: Radius.circular(24),
                                  ),
                                ),
                                // Use SingleChildScrollView to make the sheet's content scrollable
                                // when it's fully expanded, but disable scrolling when closing.
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  // Disable scrolling when the sheet is closing
                                  physics: _isSheetClosing
                                      ? const NeverScrollableScrollPhysics()
                                      : const AlwaysScrollableScrollPhysics(),
                                  child: SafeArea(
                                    top: false,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 6),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          // --- Drag Handle ---
                                          Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: 40,
                                              height: 4,
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8),
                                              decoration: ShapeDecoration(
                                                color:
                                                    Colors.white.withAlpha(80),
                                                shape: const StadiumBorder(),
                                              ),
                                            ),
                                          ),
                                          // --- Sheet Content ---
                                          Text(
                                            controller.productDetail.value
                                                    .title ??
                                                "",
                                            style: TextStyle(
                                              color: AppColors.whiteTextColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.42,
                                            ),
                                          ),
                                          hSizedBox6,
                                          Row(
                                            children: [
                                              Expanded(
                                                child: GestureDetector(
                                                  onTap: () {
                                                    Get.toNamed(
                                                        Routes.userProfile,
                                                        arguments: {
                                                          "userId": controller
                                                              .productDetail
                                                              .value
                                                              .userId
                                                        });
                                                  },
                                                  child: Row(
                                                    children: [
                                                      AppNetworkImage(
                                                        width: 24,
                                                        height: 24,
                                                        shape: BoxShape.circle,
                                                        fit: BoxFit.cover,
                                                        imageUrl: controller
                                                                .productDetail
                                                                .value
                                                                .userImage ??
                                                            "",
                                                        errorWidget: Container(
                                                          width: 24,
                                                          height: 24,
                                                          color: AppColors
                                                              .lightGreyTextColor
                                                              .withAlpha(50),
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          alignment:
                                                              Alignment.center,
                                                          child:
                                                              SvgPicture.asset(
                                                            AssetConstants.user,
                                                            color: AppColors
                                                                .whiteColor,
                                                          ),
                                                        ),
                                                      ),
                                                      wSizedBox6,
                                                      Expanded(
                                                        child: Text(
                                                          controller
                                                                  .productDetail
                                                                  .value
                                                                  .username ??
                                                              "",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: style400S14
                                                              .copyWith(
                                                            color: AppColors
                                                                .whiteTextColor,
                                                            letterSpacing: 0.42,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Obx(() {
                                                final currentUserId =
                                                    LocalStorageService
                                                        .instance
                                                        .userInfo
                                                        .value
                                                        .data
                                                        ?.id;
                                                final postUserId = controller
                                                    .productDetail.value.userId;

                                                final isOwnPost =
                                                    isNotNullOrEmpty(
                                                            currentUserId) &&
                                                        currentUserId ==
                                                            postUserId;

                                                if (isOwnPost) {
                                                  return const SizedBox
                                                      .shrink();
                                                }

                                                return controller
                                                        .isFollowing.value
                                                    ? AppButton(
                                                        onTap: controller
                                                                .isFollowLoading
                                                                .value
                                                            ? null
                                                            : () {
                                                                controller
                                                                    .toggleFollow();
                                                              },
                                                        height: 30,
                                                        text: controller
                                                                .isFollowLoading
                                                                .value
                                                            ? "..."
                                                            : "Following",
                                                        isOutlined: true,
                                                        textColor: AppColors
                                                            .whiteColor,
                                                        gradientBorderColors:
                                                            AppColors
                                                                .colorGradient,
                                                        fontSize: 13,
                                                      )
                                                    : AppButton(
                                                        onTap: controller
                                                                .isFollowLoading
                                                                .value
                                                            ? null
                                                            : () {
                                                                controller
                                                                    .toggleFollow();
                                                              },
                                                        height: 30,
                                                        text: controller
                                                                .isFollowLoading
                                                                .value
                                                            ? "..."
                                                            : "Follow",
                                                        fontSize: 13,
                                                      );
                                              }),
                                            ],
                                          ),

                                          // Animated description that appears only when sheet is expanded
                                          ValueListenableBuilder<double>(
                                            valueListenable:
                                                _sheetExtentNotifier,
                                            builder: (context, extent, child) {
                                              // Calculate how much the sheet is opened (0.0 to 1.0)
                                              final normalizedExtent =
                                                  (extent - _minSheetSize) /
                                                      (_maxSheetSize -
                                                          _minSheetSize);
                                              final clampedExtent =
                                                  normalizedExtent.clamp(
                                                      0.0, 1.0);

                                              // Show description only when sheet is significantly opened (more than 30%)
                                              final shouldShowDescription =
                                                  clampedExtent > 0.3;

                                              return AnimatedContainer(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                curve: Curves.easeInOut,
                                                height: shouldShowDescription
                                                    ? null
                                                    : 0,
                                                child: AnimatedOpacity(
                                                  duration: const Duration(
                                                      milliseconds: 200),
                                                  opacity: shouldShowDescription
                                                      ? 1.0
                                                      : 0.0,
                                                  child: shouldShowDescription
                                                      ? Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            hSizedBox10,
                                                            Text(
                                                              '${controller.productDetail.value.description ?? ""}',
                                                              style: style400S16.copyWith(
                                                                  color: const Color(
                                                                      0xFFCCCCCC),
                                                                  letterSpacing:
                                                                      0.32),
                                                            ),
                                                          ],
                                                        )
                                                      : const SizedBox.shrink(),
                                                ),
                                              );
                                            },
                                          ),
                                          hSizedBox10,
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                // Show minPrice only if it's not null AND not equal to 0
                                                if (isNotNullOrEmpty(controller
                                                        .productDetail
                                                        .value
                                                        .minPrice) &&
                                                    (int.tryParse(controller
                                                                .productDetail
                                                                .value
                                                                .minPrice!
                                                                .toString()) ??
                                                            0) !=
                                                        0)
                                                  TextSpan(
                                                    text:
                                                        "${AssetConstants.rupeeSymbol}${controller.productDetail.value.minPrice?.toFormattedPrice() ?? "-"}",
                                                    style: style600S20.copyWith(
                                                      color: AppColors
                                                          .whiteTextColor,
                                                      letterSpacing: 0.42,
                                                    ),
                                                  ),
                                                // Show maxPrice only if it's not null AND not equal to 0
                                                if (isNotNullOrEmpty(controller
                                                        .productDetail
                                                        .value
                                                        .maxPrice) &&
                                                    (int.tryParse(controller
                                                                .productDetail
                                                                .value
                                                                .maxPrice!
                                                                .toString()) ??
                                                            0) !=
                                                        0) ...[
                                                  TextSpan(
                                                    text: " to ",
                                                    style: style400S16.copyWith(
                                                      color: AppColors
                                                          .hintTextColor,
                                                      letterSpacing: 0.42,
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text:
                                                        "${AssetConstants.rupeeSymbol}${controller.productDetail.value.maxPrice?.toFormattedPrice() ?? "-"}",
                                                    style: style600S20.copyWith(
                                                      color: AppColors
                                                          .whiteTextColor,
                                                      letterSpacing: 0.42,
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          hSizedBox8,
                                          Obx(() => AppButton(
                                                onTap: () {
                                                  controller
                                                      .checkQuotationStatus(
                                                          context);
                                                },
                                                textColor: AppColors.blackColor,
                                                text: "Get Quote",
                                                isLoading:
                                                    controller.isLoading2.value,
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
