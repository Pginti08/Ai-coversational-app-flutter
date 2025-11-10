import 'dart:io';

import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_loader.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/cart/controller/cart_controller.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});
  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomScaffold(
        isEffect3: true,
        body: Padding(
          padding: EdgeInsets.only(top: Platform.isAndroid ? 6 : 0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Cart',
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
                child: controller.isLoading.value
                    ? Center(
                        child: RotatingLoader(),
                      )
                    : controller.cartList.isEmpty
                        ? Center(
                            child: Text(
                              "Your cart is empty",
                              style: style400S16,
                            ),
                          )
                        : ListView(
                            padding: EdgeInsets.only(bottom: 16),
                            controller: controller.scrollController,
                            physics: const AlwaysScrollableScrollPhysics()
                                .applyTo(const BouncingScrollPhysics()),
                            children: [
                                ListView.separated(
                                  physics: NeverScrollableScrollPhysics(),
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                  shrinkWrap: true,
                                  itemCount: controller.cartList.length,
                                  separatorBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: Divider(
                                        thickness: 0.5,
                                        color: AppColors.grey2Color,
                                      ),
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {},
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Row(
                                          children: [
                                            AppNetworkImage(
                                              width: 90,
                                              height: 120,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              imageUrl: controller
                                                      .cartList[index]
                                                      .dressImage ??
                                                  "",
                                              fit: BoxFit.cover,
                                            ),
                                            wSizedBox10,
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  hSizedBox8,
                                                  Text(
                                                    controller.cartList[index]
                                                            .title ??
                                                        "-",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: style400S16.copyWith(
                                                        letterSpacing: 0.32,
                                                        color: AppColors
                                                            .whiteTextColor),
                                                  ),
                                                  hSizedBox8,
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Flexible(
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
                                                            (controller.cartList[index].purchaseType
                                                                            ?.toLowerCase() ==
                                                                        "single"
                                                                    ? "${controller.cartList[index].bodyProfiles?.firstOrNull?.height?.toStringAsFixed(0) ?? '0'} ${(controller.cartList[index].bodyProfiles?.firstOrNull?.unit ?? "").toUpperCase()}  •  ${controller.cartList[index].bodyProfiles?.firstOrNull?.bust?.toStringAsFixed(0) ?? '0'}” | ${controller.cartList[index].bodyProfiles?.firstOrNull?.waist?.toStringAsFixed(0) ?? '0'}” | ${controller.cartList[index].bodyProfiles?.firstOrNull?.hips?.toStringAsFixed(0) ?? '0'}” | ${controller.cartList[index].bodyProfiles?.firstOrNull?.shoulders?.toStringAsFixed(0) ?? '0'}”"
                                                                        .toUpperCase()
                                                                    : controller.cartList[index].purchaseType?.toLowerCase() ==
                                                                            "bulk"
                                                                        ? bulkQuantitiesToReadableText(controller
                                                                            .cartList[index]
                                                                            .bulkQuantities)
                                                                        : "")
                                                                .toUpperCase(),
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
                                                      ),
                                                    ],
                                                  ),
                                                  hSizedBox12,
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              "Per Pc: ${AssetConstants.rupeeSymbol}${controller.cartList[index].amount?.toStringAsFixed(0) ?? "-"}",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: style400S14.copyWith(
                                                                  letterSpacing:
                                                                      0.32,
                                                                  color: AppColors
                                                                      .whiteTextColor),
                                                            ),
                                                            hSizedBox4,
                                                            Text(
                                                              "Sub Total : ${AssetConstants.rupeeSymbol}${controller.cartList[index].totalPrice?.toStringAsFixed(0) ?? "-"}",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: style400S14.copyWith(
                                                                  letterSpacing:
                                                                      0.32,
                                                                  color: AppColors
                                                                      .whiteTextColor),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      wSizedBox10,
                                                      CommonContainer(
                                                        onTap: () {
                                                          controller
                                                              .removeFromCartApi(
                                                                  controller
                                                                      .cartList[
                                                                          index]
                                                                      .id);
                                                        },
                                                        isCircle: true,
                                                        padding:
                                                            EdgeInsets.all(10),
                                                        borderGradientColors:
                                                            AppColors
                                                                .glassBorderGradient,
                                                        child: SvgPicture.asset(
                                                            AssetConstants
                                                                .remove),
                                                      )
                                                    ],
                                                  ),
                                                  hSizedBox10,
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                if (controller.paginationLoading.value)
                                  Padding(
                                    padding: EdgeInsets.all(8.w),
                                    child: Center(
                                      child: RotatingLoader(
                                        size: 30,
                                      ),
                                    ),
                                  ),
                              ]),
              ),
              SizedBox(
                height: 70.h,
              )
            ],
          ),
        ),
        bottomNavigationBar: Obx(
          () => controller.cartList.isEmpty
              ? SizedBox.shrink()
              : SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "CART",
                                  overflow: TextOverflow.ellipsis,
                                  style: style700S12.copyWith(
                                      letterSpacing: 0.3962,
                                      color: Color(0xFFCCCCCC)),
                                ),
                                Text(
                                  "${AssetConstants.rupeeSymbol}${controller.cartModel.value.data?.subTotal?.toStringAsFixed(0) ?? "-"}/-",
                                  overflow: TextOverflow.ellipsis,
                                  style: style700S18.copyWith(
                                      color: AppColors.whiteTextColor),
                                ),
                              ],
                            )),
                        wSizedBox12,
                        Expanded(
                          flex: 2,
                          child: AppButton(
                            onTap: () {
                              Get.toNamed(Routes.checkout);
                            },
                            text: "Proceed to Payment",
                          ),
                        )
                      ],
                    ),
                  ),
                ),
        )));
  }
}
