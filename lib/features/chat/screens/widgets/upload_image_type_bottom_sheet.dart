import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/custom_image_picker_cropper.dart';

class UploadImageTypeBottomSheet extends StatelessWidget {
  const UploadImageTypeBottomSheet({super.key, required this.uploadedImages});
  final List<String> uploadedImages;

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
                if (4 - uploadedImages.length > 0) {
                  capturePhoto((file) {
                    Get.back(result: [file]);
                  });
                } else {
                  toast("Maximum 4 images allowed.");
                }
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
                if (4 - uploadedImages.length > 0) {
                  imagePickerMultiple(4 - uploadedImages.length, (file) {
                    Get.back(result: file);
                  });
                } else {
                  toast("Maximum 4 images allowed.");
                }
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
