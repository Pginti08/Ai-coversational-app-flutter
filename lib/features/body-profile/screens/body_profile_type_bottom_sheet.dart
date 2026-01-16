import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/features/body-profile/screens/scan_with_ai_bottom_sheet.dart';
import 'package:vousvous/features/body-profile/screens/scanned_manually_bottom_sheet.dart';

class BodyProfileTypeBottomSheet extends StatelessWidget {
  const BodyProfileTypeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
        child: Column(
          children: [
            AppButton(
              isOutlined: true,
              isGradientBorder: true,
              gradientBorderColors: AppColors.colorGradient,
              onTap: () {
                BlurBottomSheet().show<void>(
                  height: MediaQuery.sizeOf(context).height * 0.7,
                  context: context,
                  borderColor: AppColors.whiteColor.withAlpha(
                    40,
                  ),
                  backgroundColor: AppColors.scaffoldColor.withAlpha(200),
                  barrierColor: AppColors.blackColor.withAlpha(50),
                  blurStrength: 30,
                  isCloseButton: true,
                  child: ScanWithAiBottomSheet(),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AssetConstants.magicpen,
                    color: AppColors.whiteColor,
                    width: 20,
                  ),
                  wSizedBox8,
                  Text(
                    "Scan with AI",
                    style: style700S16.copyWith(color: Color(0xFFCCCCCC)),
                  )
                ],
              ),
            ),
            Spacer(),
            AppButton(
              isOutlined: true,
              isGradientBorder: true,
              backgroundColor: AppColors.whiteColor.withAlpha(10),
              onTap: () {
                BlurBottomSheet().show<void>(
                  height: MediaQuery.sizeOf(context).height * 0.7,
                  context: context,
                  borderColor: AppColors.whiteColor.withAlpha(40),
                  backgroundColor: AppColors.scaffoldColor.withAlpha(200),
                  barrierColor: AppColors.blackColor.withAlpha(50),
                  blurStrength: 30,
                  isCloseButton: true,
                  child: ScannedManuallyBottomSheet(),
                );
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AssetConstants.add,
                    width: 20,
                  ),
                  wSizedBox8,
                  Text(
                    "Add Manually",
                    style: style700S16.copyWith(color: Color(0xFFCCCCCC)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
