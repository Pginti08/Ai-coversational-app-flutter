import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/blur_bottom_sheet.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:ai_fashion/core/widgets/custom_radio.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/cart/controller/cart_controller.dart';
import 'package:ai_fashion/features/cart/screens/add_address_bottom_sheet.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});
  final CartController controller = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isEffect3: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Select Delivery address'.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: style700S12.copyWith(
                            letterSpacing: 0.96, color: Color(0xFFCCCCCC))),
                  ],
                ),
                Positioned(
                  left: 0,
                  child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: SvgPicture.asset(AssetConstants.backward),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    hSizedBox10,
                    AppButton(
                      isOutlined: true,
                      isGradientBorder: true,
                      onTap: () {
                        BlurBottomSheet().show<void>(
                          height: MediaQuery.sizeOf(context).height * 0.9,
                          context: context,
                          borderColor: AppColors.whiteColor.withAlpha(
                            40,
                          ),
                          backgroundColor: AppColors.scaffoldColor,
                          barrierColor: AppColors.blackColor.withAlpha(100),
                          blurStrength: 30,
                          isCloseButton: true,
                          child: AddAddressBottomSheet(),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AssetConstants.add),
                          wSizedBox10,
                          Text(
                            "Add New Address",
                            style:
                                style700S16.copyWith(color: Color(0xFFCCCCCC)),
                          )
                        ],
                      ),
                    ),
                    hSizedBox24,
                    Expanded(
                      child: ListView.separated(
                        itemCount: 2,
                        separatorBuilder: (context, index) {
                          return hSizedBox16;
                        },
                        itemBuilder: (context, index) {
                          return Obx(() => CommonContainer(
                                padding: EdgeInsets.all(10),
                                borderRadius: 16,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                borderGradientColors:
                                    controller.selectedAddress.value ==
                                            "${"address $index"}"
                                        ? AppColors.colorGradient
                                        : null,
                                gradientColors:
                                    controller.selectedAddress.value ==
                                            "${"address $index"}"
                                        ? [
                                            Color(0xFF68C3E7).withAlpha(30),
                                            Color(0xFFFFB86B).withAlpha(30),
                                          ]
                                        : null,
                                child: CustomRadio<String?>(
                                  value: "address $index",
                                  groupValue: controller.selectedAddress.value,
                                  onChanged: (val) {
                                    controller.selectedAddress.value =
                                        val ?? "";
                                  },
                                  titleWidget: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Maya Patel",
                                              style: style500S18.copyWith(
                                                letterSpacing: 0.36,
                                                color: const Color(0xFFEFEFEF),
                                              ),
                                            ),
                                            Text(
                                              "45 Maple Street, Bangalore, 560001,",
                                              style: style400S14.copyWith(
                                                letterSpacing: 0.28,
                                                color: const Color(0xFFCCCCCC),
                                              ),
                                            ),
                                            hSizedBox10,
                                            Text.rich(
                                              TextSpan(
                                                children: [
                                                  TextSpan(
                                                    text: 'Mobile Number:',
                                                    style: style400S14.copyWith(
                                                      letterSpacing: 0.28,
                                                      color: const Color(
                                                          0xFF666666),
                                                    ),
                                                  ),
                                                  TextSpan(
                                                    text: ' +91 98765 43210',
                                                    style: style400S14.copyWith(
                                                      letterSpacing: 0.28,
                                                      color: const Color(
                                                          0xFFCCCCCC),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      if (controller.selectedAddress.value ==
                                          "${"address $index"}")
                                        CommonContainer(
                                            isCircle: true,
                                            backgroundColor: Colors.transparent,
                                            onTap: () {
                                              BlurBottomSheet().show<void>(
                                                height:
                                                    MediaQuery.sizeOf(context)
                                                            .height *
                                                        0.9,
                                                context: context,
                                                borderColor: AppColors
                                                    .whiteColor
                                                    .withAlpha(
                                                  40,
                                                ),
                                                backgroundColor:
                                                    AppColors.scaffoldColor,
                                                barrierColor: AppColors
                                                    .blackColor
                                                    .withAlpha(100),
                                                blurStrength: 30,
                                                isCloseButton: true,
                                                child: AddAddressBottomSheet(),
                                              );
                                            },
                                            child: SvgPicture.asset(
                                                AssetConstants.edit))
                                    ],
                                  ),
                                ),
                              ));
                        },
                      ),
                    ),
                    hSizedBox10,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              Divider(
                thickness: 0.5,
                color: AppColors.grey2Color,
              ),
              hSizedBox6,
              Row(
                children: [
                  Text(
                    "Sub Total",
                    style: style400S16.copyWith(
                        letterSpacing: 0.32, color: Color(0xFF666666)),
                  ),
                  wSizedBox10,
                  Expanded(
                      child: DottedLine(
                    dashLength: 3,
                    dashGapLength: 2,
                    dashColor: Colors.white.withAlpha(40),
                  )),
                  wSizedBox10,
                  Text(
                    "₹10,640",
                    style: style400S14.copyWith(
                        letterSpacing: 0.28, color: Color(0xFFCCCCCC)),
                  ),
                ],
              ),
              hSizedBox12,
              Row(
                children: [
                  Text(
                    "Taxes (5%)",
                    style: style400S16.copyWith(
                        letterSpacing: 0.32, color: Color(0xFF666666)),
                  ),
                  wSizedBox10,
                  Expanded(
                      child: DottedLine(
                    dashLength: 3,
                    dashGapLength: 2,
                    dashColor: Colors.white.withAlpha(40),
                  )),
                  wSizedBox10,
                  Text(
                    "₹560",
                    style: style400S14.copyWith(
                        letterSpacing: 0.28, color: Color(0xFFCCCCCC)),
                  ),
                ],
              ),
              hSizedBox12,
              Row(
                children: [
                  Text(
                    "Shipping",
                    style: style400S16.copyWith(
                        letterSpacing: 0.32, color: Color(0xFF666666)),
                  ),
                  wSizedBox10,
                  Expanded(
                      child: DottedLine(
                    dashLength: 3,
                    dashGapLength: 2,
                    dashColor: Colors.white.withAlpha(40),
                  )),
                  wSizedBox10,
                  Text(
                    "₹100",
                    style: style700S12.copyWith(
                        decoration: TextDecoration.lineThrough,
                        decorationColor: Color(0xFF666666),
                        letterSpacing: 0.96,
                        color: Color(0xFF666666)),
                  ),
                  wSizedBox4,
                  Text(
                    "₹0",
                    style: style400S14.copyWith(
                        letterSpacing: 0.28, color: Color(0xFFFFB86B)),
                  ),
                ],
              ),
              hSizedBox12,
              Row(
                children: [
                  Text(
                    "Total",
                    style: style700S16.copyWith(
                        letterSpacing: 0.32, color: Color(0xFF666666)),
                  ),
                  wSizedBox10,
                  Expanded(
                      child: DottedLine(
                    dashLength: 3,
                    dashGapLength: 2,
                    dashColor: Colors.white.withAlpha(40),
                  )),
                  wSizedBox10,
                  Text(
                    "₹11,200",
                    style: style700S16.copyWith(
                        letterSpacing: 0.32, color: Color(0xFFCCCCCC)),
                  ),
                ],
              ),
              Divider(
                color: AppColors.grey2Color,
              ),
              hSizedBox6,
              Row(
                children: [
                  Expanded(
                    child: AppButton(
                      onTap: () {},
                      text: "Pay ₹11,200",
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
