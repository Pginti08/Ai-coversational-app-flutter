import 'dart:io';

import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/quotations/controller/quotations_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class QuotationsScreen extends StatelessWidget {
  QuotationsScreen({super.key});
  final QuotationsController controller = Get.put(QuotationsController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        isBottomEffect: false,
        isBottomSafeArea: false,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16)
              .copyWith(top: Platform.isAndroid ? 6 : 0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quotations',
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
                              width: 68,
                              height: 100,
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
                                  Text(
                                    "₹3,500 to ₹7,500",
                                    overflow: TextOverflow.ellipsis,
                                    style: style400S14.copyWith(
                                        letterSpacing: 0.28,
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
                                            "172 cm  •  32” | 24” | 36”"
                                                .toUpperCase(),
                                            overflow: TextOverflow.ellipsis,
                                            style: style700S12.copyWith(
                                                letterSpacing: 0.96,
                                                color: Color(0xFFCCCCCC)),
                                          ),
                                        ),
                                      ),
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
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}
