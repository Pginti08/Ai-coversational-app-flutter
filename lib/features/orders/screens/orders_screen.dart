import 'dart:io';

import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_loader.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/orders/controller/orders_controller.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';

class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});
  final OrdersController controller = Get.put(OrdersController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => CustomScaffold(
        isBottomEffect: false,
        isBottomSafeArea: false,
        body: Padding(
          padding: EdgeInsets.only(top: Platform.isAndroid ? 6 : 0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(left: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Orders',
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
                    : controller.orderList.isEmpty
                        ? Center(
                            child: Text(
                              "No orders found",
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
                                itemCount: controller.orderList.length,
                                separatorBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    child: Divider(
                                      color: AppColors.grey2Color,
                                    ),
                                  );
                                },
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Get.toNamed(Routes.orderDetail,
                                          arguments: {
                                            "orderId":
                                                controller.orderList[index].id
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
                                                BorderRadius.circular(6),
                                            imageUrl: controller
                                                    .orderList[index]
                                                    .quotationCard
                                                    ?.dressImage ??
                                                "",
                                            fit: BoxFit.cover,
                                          ),
                                          wSizedBox10,
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    SvgPicture.asset(
                                                        AssetConstants.truck),
                                                    wSizedBox4,
                                                    GradientText(
                                                      (controller
                                                                  .orderList[
                                                                      index]
                                                                  .order
                                                                  ?.orderStatus
                                                                  ?.replaceAll(
                                                                      "_",
                                                                      " ") ??
                                                              "")
                                                          .toUpperCase(),
                                                      colors: AppColors
                                                          .colorGradient,
                                                      style:
                                                          style700S12.copyWith(
                                                              letterSpacing:
                                                                  0.96),
                                                    ),
                                                  ],
                                                ),
                                                hSizedBox8,
                                                Text(
                                                  controller
                                                          .orderList[index]
                                                          .quotationCard
                                                          ?.title ??
                                                      "",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: style500S18.copyWith(
                                                      letterSpacing: 0.32,
                                                      color: AppColors
                                                          .whiteTextColor),
                                                ),
                                                hSizedBox4,
                                                Text(
                                                  "${AssetConstants.rupeeSymbol}${controller.orderList[index].price?.toStringAsFixed(0) ?? "-"}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: style600S14.copyWith(
                                                      letterSpacing: 0.36,
                                                      color: Color(0xFFCCCCCC)),
                                                ),
                                                Text(
                                                  "Qty: ${controller.orderList[index].quantity}",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: style400S14.copyWith(
                                                      letterSpacing: 0.36,
                                                      color: Color(0xFFCCCCCC)),
                                                ),
                                              ],
                                            ),
                                          ),
                                          wSizedBox10,
                                          Transform.rotate(
                                            angle: 3.14159,
                                            child: SvgPicture.asset(
                                              AssetConstants.backward,
                                              color: AppColors.whiteColor,
                                            ),
                                          ),
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
                            ],
                          ),
              )
            ],
          ),
        )));
  }
}
