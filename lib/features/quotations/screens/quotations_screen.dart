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
                  child: Column(
                    children: [
                      Expanded(
                          child: Obx(() => controller.isLoading.value
                              ? Center(
                                  child: RotatingLoader(),
                                )
                              : controller.quotationList.isEmpty
                                  ? Center(
                                      child: Text(
                                        "Quotations not found",
                                        style: style400S16,
                                      ),
                                    )
                                  : ListView(
                                      padding: EdgeInsets.only(bottom: 16),
                                      controller: controller.scrollController,
                                      physics:
                                          const AlwaysScrollableScrollPhysics()
                                              .applyTo(
                                                  const BouncingScrollPhysics()),
                                      children: [
                                          ListView.separated(
                                            physics:
                                                NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.symmetric(
                                                vertical: 16),
                                            shrinkWrap: true,
                                            itemCount:
                                                controller.quotationList.length,
                                            separatorBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 12),
                                                child: Divider(
                                                  color: AppColors.grey2Color,
                                                ),
                                              );
                                            },
                                            itemBuilder: (context, index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  Get.toNamed(
                                                      Routes.quotationChat,
                                                      arguments: {
                                                        if (isNullOrEmpty(
                                                            controller
                                                                .quotationList[
                                                                    index]
                                                                .productId))
                                                          "imageUrl": controller
                                                                  .quotationList[
                                                                      index]
                                                                  .dressImage ??
                                                              "",
                                                        if (isNotNullOrEmpty(
                                                            controller
                                                                .quotationList[
                                                                    index]
                                                                .productId))
                                                          "productId": controller
                                                                  .quotationList[
                                                                      index]
                                                                  .productId ??
                                                              "",
                                                        if (isNotNullOrEmpty(
                                                            controller
                                                                .quotationList[
                                                                    index]
                                                                .status))
                                                          "status": controller
                                                                  .quotationList[
                                                                      index]
                                                                  .status ??
                                                              ""
                                                      });
                                                },
                                                child: Container(
                                                  color: Colors.transparent,
                                                  child: Row(
                                                    children: [
                                                      AppNetworkImage(
                                                        width: 68,
                                                        height: 100,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        imageUrl: controller
                                                                .quotationList[
                                                                    index]
                                                                .dressImage ??
                                                            "",
                                                        fit: BoxFit.cover,
                                                      ),
                                                      wSizedBox10,
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Expanded(
                                                                  child: Column(
                                                                    crossAxisAlignment:
                                                                        CrossAxisAlignment
                                                                            .start,
                                                                    children: [
                                                                      Text(
                                                                        controller.quotationList[index].title ??
                                                                            "",
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        style: style400S16.copyWith(
                                                                            letterSpacing:
                                                                                0.32,
                                                                            color:
                                                                                AppColors.whiteTextColor),
                                                                      ),
                                                                      Row(
                                                                        children: [
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  "${AssetConstants.rupeeSymbol} ${controller.quotationList[index].price?.toStringAsFixed(0) ?? 0}",
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: style400S14.copyWith(letterSpacing: 0.28, color: Color(0xFFCCCCCC)),
                                                                                ),
                                                                                hSizedBox6,
                                                                                Text(controller.quotationList[index].status?.replaceAll("_", " ") ?? "-",
                                                                                    style: style400S10.copyWith(
                                                                                        color: controller.quotationList[index].status == "DRAFT"
                                                                                            ? AppColors.greyTextColor
                                                                                            : controller.quotationList[index].status == "QUOTATION_FINALIZED"
                                                                                                ? AppColors.greenColor
                                                                                                : AppColors.yellowColor)),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          if (controller.quotationList[index].hasNewMessage ==
                                                                              true) ...[
                                                                            wSizedBox10,
                                                                            Container(
                                                                              width: 10,
                                                                              height: 10,
                                                                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.greenColor),
                                                                            ),
                                                                            wSizedBox10,
                                                                          ],
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                if (controller
                                                                        .quotationList[
                                                                            index]
                                                                        .status
                                                                        ?.toLowerCase() ==
                                                                    "draft")
                                                                  CommonContainer(
                                                                      isCircle:
                                                                          true,
                                                                      borderGradientColors:
                                                                          AppColors
                                                                              .glassBorderGradient,
                                                                      padding:
                                                                          EdgeInsets.all(
                                                                              8),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      onTap:
                                                                          () {
                                                                        commonDialog(
                                                                            title:
                                                                                "Delete Draft Quotation",
                                                                            description:
                                                                                "Are you sure you want to delete this permanently?",
                                                                            successButtonTitle:
                                                                                "Delete",
                                                                            cancelButtonTitle:
                                                                                "Cancel",
                                                                            onSuccess:
                                                                                () {
                                                                              controller.deleteQuotation(controller.quotationList[index].id);
                                                                            },
                                                                            isLoading:
                                                                                controller.isLoading2);
                                                                      },
                                                                      child: SvgPicture.asset(
                                                                          AssetConstants
                                                                              .remove))
                                                              ],
                                                            ),
                                                            hSizedBox6,
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                (controller.quotationList[index].purchaseType?.toLowerCase() ==
                                                                            "single" ||
                                                                        controller.quotationList[index].purchaseType?.toLowerCase() ==
                                                                            "bulk")
                                                                    ? Flexible(
                                                                        child:
                                                                            CommonContainer(
                                                                          padding: EdgeInsets.symmetric(
                                                                              horizontal: 10,
                                                                              vertical: 8),
                                                                          borderRadius:
                                                                              100,
                                                                          borderGradientColors:
                                                                              AppColors.glassBorderGradient,
                                                                          child:
                                                                              Text(
                                                                            controller.quotationList[index].purchaseType?.toLowerCase() == "single"
                                                                                ? "${controller.quotationList[index].bodyProfiles?.firstOrNull?.height?.toStringAsFixed(0) ?? '0'} ${(controller.quotationList[index].bodyProfiles?.firstOrNull?.heightUnit ?? "").toUpperCase()}  •  ${controller.quotationList[index].bodyProfiles?.firstOrNull?.bust?.toStringAsFixed(0) ?? '0'}” | ${controller.quotationList[index].bodyProfiles?.firstOrNull?.waist?.toStringAsFixed(0) ?? '0'}” | ${controller.quotationList[index].bodyProfiles?.firstOrNull?.hips?.toStringAsFixed(0) ?? '0'}” | ${controller.quotationList[index].bodyProfiles?.firstOrNull?.shoulders?.toStringAsFixed(0) ?? '0'}”".toUpperCase()
                                                                                : controller.quotationList[index].purchaseType?.toLowerCase() == "bulk"
                                                                                    ? bulkQuantitiesToReadableText(controller.quotationList[index].bulkQuantities)
                                                                                    : "",
                                                                            overflow:
                                                                                TextOverflow.ellipsis,
                                                                            style:
                                                                                style700S12.copyWith(letterSpacing: 0.96, color: Color(0xFFCCCCCC)),
                                                                          ),
                                                                        ),
                                                                      )
                                                                    : SizedBox
                                                                        .shrink(),
                                                                Transform
                                                                    .rotate(
                                                                  angle:
                                                                      3.14159,
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    AssetConstants
                                                                        .backward,
                                                                    color: AppColors
                                                                        .whiteColor,
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
                                              );
                                            },
                                          ),
                                          if (controller
                                              .paginationLoading.value)
                                            Padding(
                                              padding: EdgeInsets.all(8.w),
                                              child: Center(
                                                child: RotatingLoader(
                                                  size: 30,
                                                ),
                                              ),
                                            ),
                                        ]))),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
