import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/custom_image_picker_cropper.dart';

class UploadImageTypeTryOnBottomSheet extends StatelessWidget {
  const UploadImageTypeTryOnBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Text(
              "Choose Your Image",
              style: style600S16.copyWith(color: AppColors.whiteTextColor),
            ),
            hSizedBox16,
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
            hSizedBox20,
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
            Spacer(),
          ],
        ),
      ),
    );
  }
}
