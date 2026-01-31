import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';

class WhatAreAppCreditsScreen extends StatelessWidget {
  WhatAreAppCreditsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isBottomEffect: false,
      isBottomSafeArea: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6).copyWith(bottom: 0),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('What are App Credits?'.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: style700S14.copyWith(
                            color: Color(0xFFCCCCCC), letterSpacing: 0.96)),
                  ],
                ),
                Positioned(
                  left: 0,
                  child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: SvgPicture.asset(
                      AssetConstants.backward,
                      height: 24,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
                child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    hSizedBox12,
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'App Credits are virtual currency used inside the app as ',
                            style: style400S16.copyWith(
                              color: const Color(0xFFCCCCCC),
                              letterSpacing: 0.32,
                            ),
                          ),
                          TextSpan(
                            text: '0.01 ',
                            style: style600S16.copyWith(
                              color: const Color(0xFFFFB86B),
                              letterSpacing: 0.32,
                            ),
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Image.asset(
                              AssetConstants.vousvousCoin,
                              height: 16,
                              width: 16,
                            ),
                          ),
                          TextSpan(
                            text: ' = ${AssetConstants.rupeeSymbol} 1',
                            style: style600S16.copyWith(
                              color: const Color(0xFFFFB86B),
                              letterSpacing: 0.32,
                            ),
                          ),
                        ],
                      ),
                    ),
                    hSizedBox16,
                    Row(
                      children: [
                        Text('Use '.toUpperCase(),
                            textAlign: TextAlign.start,
                            style: style700S16.copyWith(
                                color: Color(0xFF999999), letterSpacing: 1.28)),
                        Image.asset(
                          AssetConstants.vousvousCoinSet,
                          height: 16,
                          width: 16,
                        ),
                        Text(' for:'.toUpperCase(),
                            textAlign: TextAlign.start,
                            style: style700S16.copyWith(
                                color: Color(0xFF999999), letterSpacing: 1.28)),
                      ],
                    ),
                    hSizedBox16,
                    creditsForTile(
                        title: "ai designs", icon: AssetConstants.aiDesign),
                    hSizedBox16,
                    creditsForTile(title: "try on", icon: AssetConstants.tryOn),
                    hSizedBox16,
                    creditsForTile(
                        title: "remixes", icon: AssetConstants.remixes),
                    hSizedBox16,
                    creditsForTile(
                        title: "order discounts",
                        icon: AssetConstants.discount),
                    hSizedBox16,
                    CommonContainer(
                      backgroundColor: AppColors.grey2Color.withAlpha(120),
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      borderRadius: 100,
                      borderGradientColors: AppColors.glassBorderGradient,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SvgPicture.asset(AssetConstants.danger),
                              wSizedBox8,
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      "Promo ",
                                      textAlign: TextAlign.start,
                                      style: style400S14.copyWith(
                                          letterSpacing: 0.28,
                                          color: Color(0xFFCCCCCC)),
                                    ),
                                    Image.asset(
                                      AssetConstants.vousvousCoin,
                                      height: 14,
                                      width: 14,
                                    ),
                                    Text(
                                      " may expire",
                                      textAlign: TextAlign.start,
                                      style: style400S14.copyWith(
                                          letterSpacing: 0.28,
                                          color: Color(0xFFCCCCCC)),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                          hSizedBox8,
                          Row(
                            children: [
                              SvgPicture.asset(AssetConstants.tickCircle2),
                              wSizedBox8,
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      "Purchased ",
                                      textAlign: TextAlign.start,
                                      style: style400S14.copyWith(
                                          letterSpacing: 0.28,
                                          color: Color(0xFFCCCCCC)),
                                    ),
                                    Image.asset(
                                      AssetConstants.vousvousCoin,
                                      height: 14,
                                      width: 14,
                                    ),
                                    Text(
                                      " never expire",
                                      textAlign: TextAlign.start,
                                      style: style400S14.copyWith(
                                          letterSpacing: 0.28,
                                          color: Color(0xFFCCCCCC)),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Row creditsForTile({required String title, required String icon}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: GradientBoxBorder(
                width: 0.5,
                gradient: LinearGradient(
                  colors: AppColors.colorGradient,
                ),
              )),
          child: SvgPicture.asset(icon),
        ),
        wSizedBox8,
        Flexible(
          child: Text(title.capitalize ?? "",
              style: style400S14.copyWith(
                  color: Color(0xFFCCCCCC), letterSpacing: 0.28)),
        )
      ],
    );
  }
}
