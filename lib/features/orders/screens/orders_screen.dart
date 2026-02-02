import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/extensions.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/orders/controller/orders_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});
  final OrdersController controller = Get.put(OrdersController());

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
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(child: RotatingLoader());
                  }

                  if (controller.orderList.isEmpty) {
                    return Center(
                      child: Text(
                        "No orders found",
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
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                      controller: controller.scrollController,
                      physics: const AlwaysScrollableScrollPhysics()
                          .applyTo(const BouncingScrollPhysics()),
                      itemCount: controller.orderList.length +
                          (controller.paginationLoading.value ? 1 : 0),
                      itemBuilder: (context, index) {
                        // Show loader at the end
                        if (index >= controller.orderList.length) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 20.h),
                            child: Center(
                              child: RotatingLoader(size: 30),
                            ),
                          );
                        }

                        final order = controller.orderList[index];
                        final isLastItem =
                            index == controller.orderList.length - 1;

                        return Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(Routes.orderDetail,
                                    arguments: {"orderId": order.id});
                              },
                              child: Container(
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    AppNetworkImage(
                                      width: 68,
                                      height: 100,
                                      borderRadius: BorderRadius.circular(6),
                                      imageUrl:
                                          order.quotationCard?.dressImage ?? "",
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
                                                getOrderStatusIcon(
                                                    order.order?.orderStatus ??
                                                        ""),
                                                color: AppColors.primaryColor,
                                                height: 20,
                                              ),
                                              wSizedBox4,
                                              GradientText(
                                                (order.order?.orderStatus
                                                            ?.replaceAll(
                                                                "_", " ") ??
                                                        "")
                                                    .toUpperCase(),
                                                colors: AppColors.colorGradient,
                                                style: style700S12.copyWith(
                                                    letterSpacing: 0.96),
                                              ),
                                            ],
                                          ),
                                          hSizedBox8,
                                          Text(
                                            order.quotationCard?.title ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            style: style500S18.copyWith(
                                                letterSpacing: 0.32,
                                                color:
                                                    AppColors.whiteTextColor),
                                          ),
                                          hSizedBox4,
                                          Row(
                                            children: [
                                              Image.asset(
                                                AssetConstants.vousvousCoin,
                                                height: 16,
                                                width: 16,
                                              ),
                                              wSizedBox4,
                                              Text(
                                                ((order.price ?? 0) / 100)
                                                    .toFormattedCoins(),
                                                overflow: TextOverflow.ellipsis,
                                                style: style600S14.copyWith(
                                                    letterSpacing: 0.36,
                                                    color: Color(0xFFCCCCCC)),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "Qty: ${order.quantity}",
                                            overflow: TextOverflow.ellipsis,
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
              )
            ],
          ),
        ));
  }
}
