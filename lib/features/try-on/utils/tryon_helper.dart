import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/features/try-on/widgets/upload_image_type_try_on_bottom_sheet.dart';
import 'package:vousvous/routes/app_pages.dart';

/// Opens the try-on bottom sheet for picking a person image, then navigates
/// to the TryOnPreviewScreen with both the person image and product image.
Future<void> openTryOnFlow({
  required BuildContext context,
  required String productImageUrl,
}) async {
  final result = await BlurBottomSheet().show<File>(
    context: context,
    height: MediaQuery.sizeOf(context).height * 0.25,
    borderColor: AppColors.whiteColor.withAlpha(40),
    backgroundColor: AppColors.scaffoldColor.withAlpha(200),
    barrierColor: AppColors.blackColor.withAlpha(50),
    blurStrength: 10,
    isCloseButton: true,
    child: const UploadImageTypeTryOnBottomSheet(),
  );

  if (result != null) {
    Get.toNamed(
      Routes.tryOnPreview,
      arguments: {
        'personImage': result.path,
        'productImage': productImageUrl,
      },
    );
  }
}
