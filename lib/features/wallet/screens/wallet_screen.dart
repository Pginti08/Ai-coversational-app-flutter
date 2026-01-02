import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/wallet/controller/wallet_controller.dart';
import 'package:vousvous/features/wallet/sub-feature/earn_credit/screens/earn_credit_screen.dart';
import 'package:vousvous/features/wallet/sub-feature/what_are_app_credits/screens/what_are_app_credits_screen.dart';
import 'package:vousvous/routes/app_pages.dart';

class WalletScreen extends StatelessWidget {
  WalletScreen({super.key});
  final WalletController controller = Get.put(WalletController());

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
                padding: EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: SvgPicture.asset(AssetConstants.backward),
                    ),
                    Text('My Wallet',
                        textAlign: TextAlign.center,
                        style:
                            style700S28.copyWith(color: AppColors.textColor)),
                    wSizedBox10,
                    Expanded(
                        child: GestureDetector(
                      onTap: () {
                        Get.to(WhatAreAppCreditsScreen());
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SvgPicture.asset(AssetConstants.infoCircle),
                          wSizedBox4,
                          Flexible(
                            child: Text(
                              "What are App Credits?",
                              textAlign: TextAlign.end,
                              overflow: TextOverflow.ellipsis,
                              style: style400S14.copyWith(
                                  letterSpacing: 0.28,
                                  color: const Color(0xFFFFB86B)),
                            ),
                          )
                        ],
                      ),
                    ))
                  ],
                ),
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CommonContainer(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        borderRadius: 16,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        borderGradientColors: AppColors.colorGradient,
                        gradientColors: [
                          Color(0xFF68C3E7).withAlpha(30),
                          Color(0xFFFFB86B).withAlpha(30),
                        ],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Available Balance",
                              textAlign: TextAlign.start,
                              style: style400S16.copyWith(
                                  letterSpacing: 0.32,
                                  color: Color(0xFFCCCCCC)),
                            ),
                            Text(
                              "12.30  Credits",
                              textAlign: TextAlign.start,
                              style: style400S24.copyWith(
                                letterSpacing: 0.48,
                              ),
                            ),
                            Text(
                              "= ${AssetConstants.rupeeSymbol}1230 value",
                              textAlign: TextAlign.start,
                              style: style400S12.copyWith(
                                  letterSpacing: 0.24,
                                  color: Color(0xFFCCCCCC)),
                            ),
                            hSizedBox16,
                            Row(
                              children: [
                                Expanded(
                                    child: AppButton(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AssetConstants.add,
                                        color: AppColors.greyBackgroundColor,
                                      ),
                                      wSizedBox2,
                                      Flexible(
                                        child: Text(
                                          "Add Credits",
                                          style: style700S16.copyWith(
                                              color: AppColors
                                                  .greyBackgroundColor),
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                                wSizedBox10,
                                Expanded(
                                    child: AppButton(
                                  onTap: () {
                                    Get.to(EarnCreditScreen());
                                  },
                                  isGradientBorder: true,
                                  isOutlined: true,
                                  gradientBorderColors: AppColors.colorGradient,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AssetConstants.gift,
                                      ),
                                      wSizedBox2,
                                      Flexible(
                                        child: Text(
                                          "Earn Credits",
                                          style: style700S16.copyWith(),
                                        ),
                                      )
                                    ],
                                  ),
                                )),
                              ],
                            )
                          ],
                        ),
                      ),
                      hSizedBox16,
                      CommonContainer(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        borderRadius: 100,
                        borderGradientColors: AppColors.glassBorderGradient,
                        child: Row(
                          children: [
                            SvgPicture.asset(AssetConstants.lamp),
                            wSizedBox8,
                            Expanded(
                              child: Text(
                                "Use Credits For AI designs, try-ons, remixes & discounts on orders.",
                                textAlign: TextAlign.start,
                                style: style400S14.copyWith(
                                    letterSpacing: 0.28,
                                    color: Color(0xFFCCCCCC)),
                              ),
                            )
                          ],
                        ),
                      ),
                      hSizedBox16,
                      optionsTile(
                        title: "Earn More Credits",
                        onTap: () {
                          Get.to(EarnCreditScreen());
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Divider(
                          color: AppColors.dividerColor,
                          thickness: 0.5,
                        ),
                      ),
                      optionsTile(
                        title: "Credit History",
                        onTap: () {
                          Get.toNamed(Routes.creditHistory);
                        },
                      ),
                    ],
                  ),
                ),
              ))
            ],
          ),
        ));
  }

  GestureDetector optionsTile({String? title, void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title ?? "",
              overflow: TextOverflow.ellipsis,
              style: style400S16.copyWith(
                letterSpacing: 0.32,
              ),
            ),
          ),
          wSizedBox4,
          Transform.rotate(
            angle: 3.14159,
            child: SvgPicture.asset(
              AssetConstants.backward,
              color: AppColors.whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
