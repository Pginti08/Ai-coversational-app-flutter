import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/routes/app_pages.dart';

class EarnCreditScreen extends StatelessWidget {
  EarnCreditScreen({super.key});

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
                    Text('Earn Credit'.toUpperCase(),
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
                    hSizedBox16,
                    earnCreditTile(
                        title: "Daily login",
                        descriptionWidget: Row(
                          children: [
                            Text("+5 ",
                                style: style400S12.copyWith(
                                    color: Color(0xFF999999),
                                    letterSpacing: 0.28)),
                            Image.asset(
                              AssetConstants.vousvousCoin,
                              width: 12,
                              height: 12,
                            ),
                            Text(" per day",
                                style: style400S12.copyWith(
                                    color: Color(0xFF999999),
                                    letterSpacing: 0.28)),
                          ],
                        ),
                        icon: AssetConstants.dailyLogin),
                    hSizedBox24,
                    earnCreditTile(
                        title: "Refer Friends",
                        descriptionWidget: Row(
                          children: [
                            Text("+100 ",
                                style: style400S12.copyWith(
                                    color: Color(0xFF999999),
                                    letterSpacing: 0.28)),
                            Image.asset(
                              AssetConstants.vousvousCoin,
                              width: 12,
                              height: 12,
                            ),
                            Text(" after signup",
                                style: style400S12.copyWith(
                                    color: Color(0xFF999999),
                                    letterSpacing: 0.28)),
                          ],
                        ),
                        icon: AssetConstants.inviteFriend,
                        extra: AppButton(
                          height: 35,
                          width: MediaQuery.sizeOf(context).width / 4,
                          text: "Refer",
                          onTap: () {
                            Get.toNamed(Routes.referFriend);
                          },
                        )),
                    hSizedBox24,
                    earnCreditTile(
                        title: "complete an order",
                        descriptionWidget: Row(
                          children: [
                            Text("up to 10% cashback in ",
                                style: style400S12.copyWith(
                                    color: Color(0xFF999999),
                                    letterSpacing: 0.28)),
                            Image.asset(
                              AssetConstants.vousvousCoin,
                              width: 12,
                              height: 12,
                            ),
                          ],
                        ),
                        icon: AssetConstants.completeOrder),
                    hSizedBox24,
                    earnCreditTile(
                        title: "First boutique purchase",
                        descriptionWidget: Row(
                          children: [
                            Text("+150 ",
                                style: style400S12.copyWith(
                                    color: Color(0xFF999999),
                                    letterSpacing: 0.28)),
                            Image.asset(
                              AssetConstants.vousvousCoin,
                              width: 12,
                              height: 12,
                            ),
                            Text(" bonus",
                                style: style400S12.copyWith(
                                    color: Color(0xFF999999),
                                    letterSpacing: 0.28)),
                          ],
                        ),
                        icon: AssetConstants.firstPurchase),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget earnCreditTile(
      {required String title,
      required Widget descriptionWidget,
      required String icon,
      Widget? extra}) {
    return CommonContainer(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      borderRadius: 18,
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      borderGradientColors: [
        Color(0xFF68C3E7).withAlpha(50),
        Color(0xFFFFB86B).withAlpha(50),
      ],
      gradientColors: [
        Color(0xFF68C3E7).withAlpha(17),
        Color(0xFFFFB86B).withAlpha(17),
      ],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 40,
            width: 40,
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: GradientBoxBorder(
                  width: 0.5,
                  gradient: LinearGradient(
                    colors: AppColors.colorGradient,
                  ),
                )),
            child: SvgPicture.asset(
              icon,
              height: 28,
            ),
          ),
          wSizedBox12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(),
                    overflow: TextOverflow.ellipsis,
                    style: style700S12.copyWith(
                        color: Color(0xFFCCCCCC), letterSpacing: 0.96)),
                hSizedBox2,
                descriptionWidget,
              ],
            ),
          ),
          wSizedBox10,
          if (extra != null) extra
        ],
      ),
    );
  }
}
