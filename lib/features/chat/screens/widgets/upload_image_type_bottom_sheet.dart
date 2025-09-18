import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/custom_image_picker_cropper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class UploadImageTypeBottomSheet extends StatelessWidget {
  const UploadImageTypeBottomSheet({super.key});

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
              backgroundColor: AppColors.whiteColor.withAlpha(15),
              onTap: () {
                capturePhoto((file) {
                  Get.back(result: file);
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AssetConstants.camera,
                    height: 20,
                  ),
                  wSizedBox8,
                  Text(
                    "Camera",
                    style: style700S16.copyWith(color: Color(0xFFCCCCCC)),
                  )
                ],
              ),
            ),
            Spacer(),
            AppButton(
              isOutlined: true,
              isGradientBorder: true,
              backgroundColor: AppColors.whiteColor.withAlpha(15),
              onTap: () {
                imagePicker((file) {
                  Get.back(result: file);
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AssetConstants.gallery,
                    height: 20,
                  ),
                  wSizedBox8,
                  Text(
                    "Gallery",
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
