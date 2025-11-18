import 'dart:ui';

import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/product-detail/controller/product_detail_controller.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

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

    return CustomScaffold(
      isBottomSafeArea: false,
      body: Stack(
        children: [
          // --- Background Content ---
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: SvgPicture.asset(
                    AssetConstants.backward,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ValueListenableBuilder<double>(
                      valueListenable: _sheetExtentNotifier,
                      builder: (context, extent, child) {
                        final normalizedExtent = (extent - _minSheetSize) /
                            (_maxSheetSize - _minSheetSize);
                        final clampedExtent = normalizedExtent.clamp(0.0, 1.0);

                        final imageHeight = lerpDouble(initialImageHeight,
                            finalImageHeight, clampedExtent);

                        final imageWidth = lerpDouble(
                            initialImageWidth, finalImageWidth, clampedExtent);
                        final imageBorderRadius = lerpDouble(
                            initialBorderRadius,
                            finalBorderRadius,
                            clampedExtent);

                        return ClipRRect(
                          borderRadius:
                              BorderRadius.circular(imageBorderRadius ?? 0),
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
                        imageUrl: controller.productDetail?.image ?? "",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
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
              builder:
                  (BuildContext context, ScrollController scrollController) {
                // The content of the bottom sheet.
                return ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(150),
                        border: GradientBoxBorder(
                          width: 1,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: AppColors.glassBorderGradient,
                          ),
                        ),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // --- Drag Handle ---
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    width: 40,
                                    height: 4,
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: ShapeDecoration(
                                      color: Colors.white.withAlpha(80),
                                      shape: const StadiumBorder(),
                                    ),
                                  ),
                                ),
                                // --- Sheet Content ---
                                Text(
                                  controller.productDetail?.title ?? "",
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
                                    AppNetworkImage(
                                      width: 24,
                                      height: 24,
                                      shape: BoxShape.circle,
                                      fit: BoxFit.cover,
                                      imageUrl:
                                          controller.productDetail?.userImage ??
                                              "",
                                      errorWidget: Container(
                                        width: 24,
                                        height: 24,
                                        color: AppColors.lightGreyTextColor
                                            .withAlpha(50),
                                        padding: EdgeInsets.all(5),
                                        alignment: Alignment.center,
                                        child: SvgPicture.asset(
                                          AssetConstants.user,
                                          color: AppColors.whiteColor,
                                        ),
                                      ),
                                    ),
                                    wSizedBox6,
                                    Text(
                                      controller.productDetail?.userName ?? "",
                                      style: style400S14.copyWith(
                                        color: AppColors.whiteTextColor,
                                        letterSpacing: 0.42,
                                      ),
                                    ),
                                  ],
                                ),
                                // Animated description that appears only when sheet is expanded
                                ValueListenableBuilder<double>(
                                  valueListenable: _sheetExtentNotifier,
                                  builder: (context, extent, child) {
                                    // Calculate how much the sheet is opened (0.0 to 1.0)
                                    final normalizedExtent =
                                        (extent - _minSheetSize) /
                                            (_maxSheetSize - _minSheetSize);
                                    final clampedExtent =
                                        normalizedExtent.clamp(0.0, 1.0);

                                    // Show description only when sheet is significantly opened (more than 30%)
                                    final shouldShowDescription =
                                        clampedExtent > 0.3;

                                    return AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                      height: shouldShowDescription ? null : 0,
                                      child: AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        opacity:
                                            shouldShowDescription ? 1.0 : 0.0,
                                        child: shouldShowDescription
                                            ? Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  hSizedBox10,
                                                  Text(
                                                    '''Description:
${controller.productDetail?.description ?? ""}''',
                                                    style: style400S16.copyWith(
                                                        color: const Color(
                                                            0xFFCCCCCC),
                                                        letterSpacing: 0.32),
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
                                      if (isNotNullOrEmpty(controller
                                              .productDetail?.minPrice) ||
                                          int.tryParse(controller
                                                  .productDetail!.minPrice!
                                                  .toString()) !=
                                              0)
                                        TextSpan(
                                          text:
                                              "${AssetConstants.rupeeSymbol}${controller.productDetail?.minPrice?.toStringAsFixed(0) ?? "-"}",
                                          style: style600S20.copyWith(
                                            color: AppColors.whiteTextColor,
                                            letterSpacing: 0.42,
                                          ),
                                        ),
                                      if (isNotNullOrEmpty(controller
                                              .productDetail?.maxPrice) ||
                                          int.tryParse(controller
                                                  .productDetail!.maxPrice!
                                                  .toString()) !=
                                              0) ...[
                                        TextSpan(
                                          text: " to ",
                                          style: style400S16.copyWith(
                                            color: AppColors.hintTextColor,
                                            letterSpacing: 0.42,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              "${AssetConstants.rupeeSymbol}${controller.productDetail?.maxPrice?.toStringAsFixed(0) ?? "-"}",
                                          style: style600S20.copyWith(
                                            color: AppColors.whiteTextColor,
                                            letterSpacing: 0.42,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                hSizedBox8,
                                AppButton(
                                  onTap: () {
                                    Get.toNamed(Routes.quotationChat,
                                        arguments: {
                                          "productId":
                                              controller.productDetail?.id
                                        });
                                  },
                                  textColor: AppColors.blackColor,
                                  text: "Get Quote",
                                ),
                              ],
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
    );
  }
}
