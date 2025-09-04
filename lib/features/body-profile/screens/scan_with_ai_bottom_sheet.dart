import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/blur_bottom_sheet.dart';
import 'package:ai_fashion/core/widgets/bullet_point_list.dart';
import 'package:ai_fashion/features/body-profile/screens/scanned_manually_bottom_sheet.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class ScanWithAiBottomSheet extends StatelessWidget {
  const ScanWithAiBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Text(
              "Scan with AI".toUpperCase(),
              style: style700S12.copyWith(
                  letterSpacing: 0.96, color: Color(0xFFCCCCCC)),
            ),
            hSizedBox20,
            Row(
              children: [
                Expanded(child: Image.asset(AssetConstants.frontBody)),
                wSizedBox10,
                Expanded(child: Image.asset(AssetConstants.sideBody)),
                wSizedBox10,
                Expanded(child: Image.asset(AssetConstants.backBody)),
              ],
            ),
            hSizedBox12,
            SizedBox(
              height: 140,
              child: Row(
                children: [
                  Expanded(
                      child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      color: const Color(0xFF666666),
                      dashPattern: const [8, 4],
                      radius: const Radius.circular(14),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AssetConstants.add),
                          hSizedBox10,
                          Text(
                            "Front",
                            style:
                                style700S16.copyWith(color: Color(0xFFCCCCCC)),
                          )
                        ],
                      ),
                    ),
                  )),
                  wSizedBox10,
                  Expanded(
                      child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      color: const Color(0xFF666666),
                      dashPattern: const [8, 4],
                      radius: const Radius.circular(14),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AssetConstants.add),
                          hSizedBox10,
                          Text(
                            "Side",
                            style:
                                style700S16.copyWith(color: Color(0xFFCCCCCC)),
                          )
                        ],
                      ),
                    ),
                  )),
                  wSizedBox10,
                  Expanded(
                      child: DottedBorder(
                    options: RoundedRectDottedBorderOptions(
                      color: const Color(0xFF666666),
                      dashPattern: const [8, 4],
                      radius: const Radius.circular(14),
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AssetConstants.add),
                          hSizedBox10,
                          Text(
                            "Back",
                            style:
                                style700S16.copyWith(color: Color(0xFFCCCCCC)),
                          )
                        ],
                      ),
                    ),
                  ))
                ],
              ),
            ),
            hSizedBox10,
            BulletPointList(items: const [
              "Front full-body image",
              "Side full-body image",
              "Back full-body image",
              "Good lighting is essential",
              "Use a neutral background"
            ]),
            Spacer(),
            AppButton(
              isOutlined: true,
              isGradientBorder: true,
              backgroundColor: AppColors.whiteColor.withAlpha(10),
              text: "Proceed to Scan",
              textColor: const Color(0xFFCCCCCC),
              onTap: () {
                BlurBottomSheet().show<void>(
                  height: MediaQuery.sizeOf(context).height * 0.7,
                  context: context,
                  borderColor: AppColors.whiteColor.withAlpha(
                    40,
                  ),
                  backgroundColor: AppColors.scaffoldColor,
                  barrierColor: AppColors.blackColor.withAlpha(50),
                  blurStrength: 30,
                  isCloseButton: true,
                  child: ScannedManuallyBottomSheet(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
