import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/common_dialog.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/quotations/controller/quotations_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class QuotationsScreen extends StatelessWidget {
  QuotationsScreen({super.key});
  final QuotationsController controller = Get.put(QuotationsController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        isBottomEffect: false,
        isBottomSafeArea: false,
        body: Padding(
          padding: EdgeInsets.only(top: Platform.isAndroid ? 6 : 0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Quotations',
                        textAlign: TextAlign.center,
                        style:
                            style700S28.copyWith(color: AppColors.textColor)),
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: SvgPicture.asset(AssetConstants.closeIcon),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(child: RotatingLoader());
                    }

                    if (controller.quotationList.isEmpty) {
                      return Center(
                        child: Text(
                          "No quotations available",
                          style: style400S16,
                        ),
                      );
                    }

                    return NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        // Detect when user scrolls near the bottom
                        if (scrollInfo.metrics.pixels >=
                            scrollInfo.metrics.maxScrollExtent - 200) {
                          controller.onScrollEndReached();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.only(top: 16, bottom: 16),
                        controller: controller.scrollController,
                        physics: const AlwaysScrollableScrollPhysics()
                            .applyTo(const BouncingScrollPhysics()),
                        itemCount: controller.quotationList.length +
                            (controller.paginationLoading.value ? 1 : 0),
                        itemBuilder: (context, index) {
                          // Show loader at the end
                          if (index >= controller.quotationList.length) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: Center(
                                child: RotatingLoader(size: 30),
                              ),
                            );
                          }

                          final quotation = controller.quotationList[index];
                          final isLastItem =
                              index == controller.quotationList.length - 1;

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(Routes.quotationChat, arguments: {
                                    "imageUrl": quotation.dressImage ?? "",
                                    "productId": quotation.productId ?? "",
                                    "quotationId": quotation.id,
                                    if (isNotNullOrEmpty(quotation.status))
                                      "status": quotation.status ?? ""
                                  });
                                },
                                child: Container(
                                  color: Colors.transparent,
                                  child: Row(
                                    children: [
                                      AppNetworkImage(
                                        width: 68,
                                        height: 100,
                                        borderRadius: BorderRadius.circular(12),
                                        imageUrl: quotation.dressImage ?? "",
                                        fit: BoxFit.cover,
                                      ),
                                      wSizedBox10,
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        quotation.title ?? "",
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: style400S16.copyWith(
                                                            letterSpacing: 0.32,
                                                            color: AppColors
                                                                .whiteTextColor),
                                                      ),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Expanded(
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                if (isNotNullOrEmpty(
                                                                        quotation
                                                                            .price) &&
                                                                    (quotation.price ??
                                                                            0) !=
                                                                        0)
                                                                  Text(
                                                                    "${AssetConstants.rupeeSymbol} ${quotation.price?.toStringAsFixed(0) ?? 0}",
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style: style400S14.copyWith(
                                                                        letterSpacing:
                                                                            0.28,
                                                                        color: Color(
                                                                            0xFFCCCCCC)),
                                                                  ),
                                                                hSizedBox6,
                                                                Text(
                                                                    quotation.status?.replaceAll(
                                                                            "_",
                                                                            " ") ??
                                                                        "-",
                                                                    style: style400S10.copyWith(
                                                                        color: quotation.status == "DRAFT"
                                                                            ? AppColors.greyTextColor
                                                                            : quotation.status == "QUOTATION_FINALIZED"
                                                                                ? AppColors.greenColor
                                                                                : AppColors.yellowColor)),
                                                              ],
                                                            ),
                                                          ),
                                                          if (quotation
                                                                  .hasNewMessage ==
                                                              true) ...[
                                                            wSizedBox10,
                                                            SvgPicture.asset(
                                                              AssetConstants
                                                                  .notification,
                                                              colorFilter:
                                                                  ColorFilter.mode(
                                                                      AppColors
                                                                          .greenColor,
                                                                      BlendMode
                                                                          .srcIn),
                                                            ),
                                                            wSizedBox10,
                                                          ],
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                if (quotation.status
                                                        ?.toLowerCase() ==
                                                    "draft") ...[
                                                  wSizedBox6,
                                                  CommonContainer(
                                                      isCircle: true,
                                                      borderGradientColors:
                                                          AppColors
                                                              .glassBorderGradient,
                                                      padding:
                                                          EdgeInsets.all(8),
                                                      backgroundColor:
                                                          Colors.transparent,
                                                      onTap: () {
                                                        commonDialog(
                                                            title:
                                                                "Delete Draft Quotation",
                                                            description:
                                                                "Are you sure you want to delete this permanently?",
                                                            successButtonTitle:
                                                                "Delete",
                                                            cancelButtonTitle:
                                                                "Cancel",
                                                            onSuccess: () {
                                                              controller
                                                                  .deleteQuotation(
                                                                      quotation
                                                                          .id);
                                                            },
                                                            isLoading: controller
                                                                .isLoading2);
                                                      },
                                                      child: SvgPicture.asset(
                                                          AssetConstants
                                                              .remove))
                                                ]
                                              ],
                                            ),
                                            hSizedBox6,
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                (quotation.purchaseType
                                                                ?.toLowerCase() ==
                                                            "single" ||
                                                        quotation.purchaseType
                                                                ?.toLowerCase() ==
                                                            "bulk")
                                                    ? Flexible(
                                                        child: CommonContainer(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      10,
                                                                  vertical: 8),
                                                          borderRadius: 100,
                                                          borderGradientColors:
                                                              AppColors
                                                                  .glassBorderGradient,
                                                          child: Text(
                                                            controller
                                                                        .quotationList[
                                                                            index]
                                                                        .purchaseType
                                                                        ?.toLowerCase() ==
                                                                    "single"
                                                                ? "${controller.quotationList[index].bodyProfiles?.firstOrNull?.height?.toStringAsFixed(0) ?? '0'} ${(controller.quotationList[index].bodyProfiles?.firstOrNull?.heightUnit ?? "").toUpperCase()}  •  ${controller.quotationList[index].bodyProfiles?.firstOrNull?.bust?.toStringAsFixed(0) ?? '0'}” | ${controller.quotationList[index].bodyProfiles?.firstOrNull?.waist?.toStringAsFixed(0) ?? '0'}” | ${controller.quotationList[index].bodyProfiles?.firstOrNull?.hips?.toStringAsFixed(0) ?? '0'}” | ${controller.quotationList[index].bodyProfiles?.firstOrNull?.shoulders?.toStringAsFixed(0) ?? '0'}”"
                                                                    .toUpperCase()
                                                                : controller
                                                                            .quotationList[
                                                                                index]
                                                                            .purchaseType
                                                                            ?.toLowerCase() ==
                                                                        "bulk"
                                                                    ? bulkQuantitiesToReadableText(controller
                                                                        .quotationList[
                                                                            index]
                                                                        .bulkQuantities)
                                                                    : "",
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: style700S12
                                                                .copyWith(
                                                                    letterSpacing:
                                                                        0.96,
                                                                    color: Color(
                                                                        0xFFCCCCCC)),
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox.shrink(),
                                                Transform.rotate(
                                                  angle: 3.14159,
                                                  child: SvgPicture.asset(
                                                    AssetConstants.backward,
                                                    color: AppColors.whiteColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              // Add divider except for last item or before loader
                              if (!isLastItem)
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Divider(
                                    color: AppColors.grey2Color,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    );
                  }),
                ),
              )
            ],
          ),
        ));
  }
}
