import 'dart:io';

import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/cart/controller/cart_controller.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});
  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isEffect3: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16)
            .copyWith(top: Platform.isAndroid ? 6 : 0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Cart',
                    textAlign: TextAlign.center,
                    style: style700S28.copyWith(color: AppColors.textColor)),
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: SvgPicture.asset(AssetConstants.closeIcon),
                )
              ],
            ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(vertical: 16),
                itemCount: 3,
                separatorBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                            width: 100,
                            height: 150,
                            borderRadius: BorderRadius.circular(12),
                            imageUrl:
                                "https://framerusercontent.com/images/ioTL88ZpHCWXDdmKwFbhBBMJfA.png",
                            fit: BoxFit.cover,
                          ),
                          wSizedBox10,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Midnight Bloom Striped Elegance",
                                  overflow: TextOverflow.ellipsis,
                                  style: style400S16.copyWith(
                                      letterSpacing: 0.32,
                                      color: AppColors.whiteTextColor),
                                ),
                                hSizedBox10,
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
                                          "172 cm  •  32” | 24” | 36”"
                                              .toUpperCase(),
                                          overflow: TextOverflow.ellipsis,
                                          style: style700S12.copyWith(
                                              letterSpacing: 0.96,
                                              color: Color(0xFFCCCCCC)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                hSizedBox30,
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "₹2,800/-",
                                        overflow: TextOverflow.ellipsis,
                                        style: style400S16.copyWith(
                                            letterSpacing: 0.32,
                                            color: AppColors.whiteTextColor),
                                      ),
                                    ),
                                    wSizedBox10,
                                    CommonContainer(
                                      onTap: () {},
                                      isCircle: true,
                                      padding: EdgeInsets.all(10),
                                      borderGradientColors:
                                          AppColors.glassBorderGradient,
                                      child: SvgPicture.asset(
                                          AssetConstants.remove),
                                    )
                                  ],
                                ),
                                hSizedBox14,
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
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
                            letterSpacing: 0.3962, color: Color(0xFFCCCCCC)),
                      ),
                      Text(
                        "₹11,200/-",
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
    );
  }
}
