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

class CreditHistoryScreen extends StatelessWidget {
  CreditHistoryScreen({super.key});

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
                    Text('Credit History'.toUpperCase(),
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
                    icon: SvgPicture.asset(AssetConstants.backward),
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
                    // Text('App Credits',
                    //     textAlign: TextAlign.start,
                    //     style: style400S16.copyWith(
                    //         color: Color(0xFFCCCCCC), letterSpacing: 0.32)),
                    hSizedBox16,
                    creditHistoryTile(
                        title: "order cashback", icon: AssetConstants.add),
                    hSizedBox24,
                    creditHistoryTile(
                        title: "ai design generate",
                        icon: AssetConstants.tryOn),
                    hSizedBox24,
                    creditHistoryTile(
                        title: "credits purchased",
                        icon: AssetConstants.remixes),
                    hSizedBox24,
                    creditHistoryTile(
                        title: "try-on session", icon: AssetConstants.minus),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget creditHistoryTile({required String title, required String icon}) {
    return CommonContainer(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                Text("04/10/2024, 18:00",
                    overflow: TextOverflow.ellipsis,
                    style: style400S12.copyWith(
                        color: Color(0xFF999999), letterSpacing: 0.28)),
              ],
            ),
          ),
          wSizedBox10,
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '+120',
                  style: style400S20.copyWith(
                    color: Colors.white.withValues(alpha: 0.80),
                    letterSpacing: 0.40,
                  ),
                ),
                TextSpan(
                  text: ' credits',
                  style: style400S14.copyWith(
                    color: const Color(0xFF999999),
                    letterSpacing: 0.28,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
