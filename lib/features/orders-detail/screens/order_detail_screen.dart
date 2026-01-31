import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/orders-detail/controller/order_detail_controller.dart';
import 'package:vousvous/features/orders-detail/screens/widgets/shipping_progress_bar_horizontally.dart';
import 'package:vousvous/routes/app_pages.dart';

class OrderDetailScreen extends StatelessWidget {
  OrderDetailScreen({super.key});
  final OrderDetailController controller = Get.put(OrderDetailController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        isBottomEffect: false,
        isBottomSafeArea: false,
        body: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: SvgPicture.asset(
                    AssetConstants.backward,
                    width: 22,
                  ),
                ),
                Text('Order Details',
                    textAlign: TextAlign.center,
                    style:
                        style500S20.copyWith(color: AppColors.whiteTextColor)),
              ],
            ),
            Expanded(
                child: Obx(() => controller.isLoading.value
                    ? Center(
                        child: RotatingLoader(),
                      )
                    : ListView(
                        padding: EdgeInsets.all(10),
                        children: [
                          CommonContainer(
                            padding: EdgeInsets.all(10),
                            borderRadius: 24,
                            borderGradientColors: AppColors.glassBorderGradient,
                            backgroundColor: AppColors.whiteColor.withAlpha(25),
                            child: Row(
                              children: [
                                AppNetworkImage(
                                  width: 85,
                                  height: 130,
                                  borderRadius: BorderRadius.circular(12),
                                  imageUrl: controller.orderDetailModel.value
                                          .quotationCard?.dressImage ??
                                      "",
                                  fit: BoxFit.cover,
                                ),
                                wSizedBox10,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Order ID: ${controller.orderDetailModel.value.order?.orderUniqueId ?? "-"}"
                                            .toUpperCase(),
                                        overflow: TextOverflow.ellipsis,
                                        style: style700S12.copyWith(
                                            letterSpacing: 0.96,
                                            color: Color(0xFF666666)),
                                      ),
                                      hSizedBox10,
                                      Text(
                                        controller.orderDetailModel.value
                                                .quotationCard?.title ??
                                            "-",
                                        overflow: TextOverflow.ellipsis,
                                        style: style400S16.copyWith(
                                            letterSpacing: 0.32,
                                            color: AppColors.whiteTextColor),
                                      ),
                                      Text(
                                        "${AssetConstants.rupeeSymbol}${controller.orderDetailModel.value.price?.toStringAsFixed(0) ?? "-"}",
                                        overflow: TextOverflow.ellipsis,
                                        style: style500S18.copyWith(
                                            letterSpacing: 0.36,
                                            color: Color(0xFFCCCCCC)),
                                      ),
                                      hSizedBox14,
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Flexible(
                                            child: CommonContainer(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10, vertical: 8),
                                              borderRadius: 100,
                                              borderGradientColors:
                                                  AppColors.glassBorderGradient,
                                              child: Text(
                                                controller
                                                            .orderDetailModel
                                                            .value
                                                            .quotationCard
                                                            ?.purchaseType
                                                            ?.toLowerCase() ==
                                                        "single"
                                                    ? "${controller.orderDetailModel.value.quotationCard?.sizeMeasurement}"
                                                        .toUpperCase()
                                                    : controller
                                                                .orderDetailModel
                                                                .value
                                                                .quotationCard
                                                                ?.purchaseType
                                                                ?.toLowerCase() ==
                                                            "bulk"
                                                        ? bulkQuantitiesToReadableText(controller
                                                                .orderDetailModel
                                                                .value
                                                                .quotationCard
                                                                ?.bulkQuantities ??
                                                            "")
                                                        : "-",
                                                overflow: TextOverflow.ellipsis,
                                                style: style700S12.copyWith(
                                                    letterSpacing: 0.96,
                                                    color: Color(0xFF666666)),
                                              ),
                                            ),
                                          ),
                                          // CommonContainer(
                                          //   isCircle: true,
                                          //   gradientColors:
                                          //       AppColors.colorGradient,
                                          //   padding: EdgeInsets.all(7),
                                          //   child: SvgPicture.asset(
                                          //     AssetConstants.aiChat,
                                          //     color: AppColors.blackColor,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          if ((controller.orderDetailModel.value.tracking
                                      ?.length ??
                                  0) !=
                              0) ...[
                            hSizedBox24,
                            CommonContainer(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                borderRadius: 24,
                                borderGradientColors:
                                    AppColors.glassBorderGradient,
                                backgroundColor:
                                    AppColors.whiteColor.withAlpha(25),
                                child: Row(children: [
                                  Expanded(
                                      child: Column(
                                    children: [
                                      ShippingProgressBarHorizontally(
                                        tracking: controller.orderDetailModel
                                                .value.tracking ??
                                            [],
                                        activeColor: Color(0xFF4FC3F7),
                                        inactiveColor: Color(0xFF757575),
                                      ),
                                      hSizedBox20,
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                        ),
                                        child: AppButton(
                                          onTap: () {
                                            Get.toNamed(Routes.trackingDetail);
                                          },
                                          textColor: AppColors.whiteColor,
                                          backgroundColor:
                                              AppColors.whiteColor.withAlpha(5),
                                          gradientBorderColors:
                                              AppColors.glassBorderGradient,
                                          text: "View Tracking Details",
                                        ),
                                      ),
                                    ],
                                  ))
                                ])),
                          ],
                          hSizedBox24,
                          CommonContainer(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            borderRadius: 24,
                            borderGradientColors: AppColors.glassBorderGradient,
                            backgroundColor: AppColors.whiteColor.withAlpha(25),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Shipping Details".toUpperCase(),
                                        overflow: TextOverflow.ellipsis,
                                        style: style700S12.copyWith(
                                            letterSpacing: 0.96,
                                            color: Color(0xFF666666)),
                                      ),
                                      hSizedBox10,
                                      Text(
                                        controller.orderDetailModel.value.order
                                                ?.addressText ??
                                            "",
                                        overflow: TextOverflow.ellipsis,
                                        style: style500S18.copyWith(
                                            letterSpacing: 0.36,
                                            color: Color(0xFFEFEFEF)),
                                      ),
                                      // Text(
                                      //   "78 Oak Avenue, Mumbai, 400012,",
                                      //   overflow: TextOverflow.ellipsis,
                                      //   style: style400S14.copyWith(
                                      //       letterSpacing: 0.28,
                                      //       color: Color(0xFFCCCCCC)),
                                      // ),
                                      // hSizedBox14,
                                      // Text.rich(
                                      //   TextSpan(
                                      //     children: [
                                      //       TextSpan(
                                      //         text: 'Mobile Number: ',
                                      //         style: style400S14.copyWith(
                                      //           color: const Color(0xFF666666),
                                      //           letterSpacing: 0.28,
                                      //         ),
                                      //       ),
                                      //       TextSpan(
                                      //         text: '+91 91234 56789',
                                      //         style: style400S14.copyWith(
                                      //           color: const Color(0xFFEFEFEF),
                                      //           letterSpacing: 0.28,
                                      //         ),
                                      //       ),
                                      //     ],
                                      //   ),
                                      // )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          hSizedBox24,
                          CommonContainer(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            borderRadius: 24,
                            borderGradientColors: AppColors.glassBorderGradient,
                            backgroundColor: AppColors.whiteColor.withAlpha(25),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Payment Details".toUpperCase(),
                                        overflow: TextOverflow.ellipsis,
                                        style: style700S12.copyWith(
                                            letterSpacing: 0.96,
                                            color: Color(0xFF666666)),
                                      ),
                                      hSizedBox10,
                                      Row(
                                        children: [
                                          Text(
                                            "Sub Total",
                                            style: style400S16.copyWith(
                                                letterSpacing: 0.32,
                                                color: Color(0xFF666666)),
                                          ),
                                          wSizedBox10,
                                          Expanded(
                                              child: DottedLine(
                                            dashLength: 3,
                                            dashGapLength: 2,
                                            dashColor:
                                                Colors.white.withAlpha(40),
                                          )),
                                          wSizedBox10,
                                          Text(
                                            "${AssetConstants.rupeeSymbol}${controller.orderDetailModel.value.order?.subTotal?.toStringAsFixed(0) ?? "-"}",
                                            style: style400S14.copyWith(
                                                letterSpacing: 0.28,
                                                color: Color(0xFFCCCCCC)),
                                          ),
                                        ],
                                      ),
                                      hSizedBox12,
                                      Row(
                                        children: [
                                          Text(
                                            "Taxes",
                                            style: style400S16.copyWith(
                                                letterSpacing: 0.32,
                                                color: Color(0xFF666666)),
                                          ),
                                          wSizedBox10,
                                          Expanded(
                                              child: DottedLine(
                                            dashLength: 3,
                                            dashGapLength: 2,
                                            dashColor:
                                                Colors.white.withAlpha(40),
                                          )),
                                          wSizedBox10,
                                          Text(
                                            "${AssetConstants.rupeeSymbol}${controller.orderDetailModel.value.order?.taxAmount?.toStringAsFixed(0) ?? "-"}",
                                            style: style400S14.copyWith(
                                                letterSpacing: 0.28,
                                                color: Color(0xFFCCCCCC)),
                                          ),
                                        ],
                                      ),
                                      hSizedBox12,
                                      Row(
                                        children: [
                                          Text(
                                            "Shipping",
                                            style: style400S16.copyWith(
                                                letterSpacing: 0.32,
                                                color: Color(0xFF666666)),
                                          ),
                                          wSizedBox10,
                                          Expanded(
                                              child: DottedLine(
                                            dashLength: 3,
                                            dashGapLength: 2,
                                            dashColor:
                                                Colors.white.withAlpha(40),
                                          )),
                                          wSizedBox10,
                                          Text(
                                            "${AssetConstants.rupeeSymbol}${controller.orderDetailModel.value.order?.shippingCharge?.toStringAsFixed(0) ?? "-"}",
                                            style: style400S14.copyWith(
                                                letterSpacing: 0.28,
                                                color: Color(0xFFFFB86B)),
                                          ),
                                        ],
                                      ),
                                      hSizedBox12,
                                      Row(
                                        children: [
                                          Text(
                                            "Total",
                                            style: style700S16.copyWith(
                                              letterSpacing: 0.32,
                                            ),
                                          ),
                                          Spacer(),
                                          Text(
                                            "${AssetConstants.rupeeSymbol}${controller.orderDetailModel.value.order?.totalAmount?.toStringAsFixed(0) ?? "-"}",
                                            style: style700S16.copyWith(
                                                letterSpacing: 0.32,
                                                color: Color(0xFFCCCCCC)),
                                          ),
                                        ],
                                      ),
                                      hSizedBox14,
                                      Obx(() => AppButton(
                                            onTap: () {
                                              if (controller
                                                      .orderDetailModel
                                                      .value
                                                      .order
                                                      ?.orderStatus !=
                                                  "PENDING_PAYMENT") {
                                                controller.downloadPdf();
                                              }
                                            },
                                            textColor: AppColors.whiteColor,
                                            loaderColor: AppColors.whiteColor,
                                            backgroundColor: AppColors
                                                .whiteColor
                                                .withAlpha(5),
                                            gradientBorderColors:
                                                AppColors.glassBorderGradient,
                                            isLoading:
                                                controller.isLoading2.value,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  AssetConstants.invoice,
                                                  colorFilter: ColorFilter.mode(
                                                      controller
                                                                  .orderDetailModel
                                                                  .value
                                                                  .order
                                                                  ?.orderStatus !=
                                                              "PENDING_PAYMENT"
                                                          ? Color(0xFFCCCCCC)
                                                          : Color(0xFF525252),
                                                      BlendMode.srcIn),
                                                ),
                                                wSizedBox4,
                                                Text(
                                                  "Download Invoice",
                                                  style: style700S16.copyWith(
                                                      color: controller
                                                                  .orderDetailModel
                                                                  .value
                                                                  .order
                                                                  ?.orderStatus !=
                                                              "PENDING_PAYMENT"
                                                          ? Color(0xFFCCCCCC)
                                                          : Color(0xFF525252)),
                                                )
                                              ],
                                            ),
                                          )),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      )))
          ],
        ));
  }
}
