import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/blur_scaffold.dart';
import 'package:vousvous/features/quotation-chat/controller/quotation_chat_controller.dart';
import 'package:vousvous/features/share-preview/controller/share_preview_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class SharePreviewScreen extends StatefulWidget {
  const SharePreviewScreen({super.key});

  @override
  State<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends State<SharePreviewScreen> {
  final controller = Get.put(SharePreviewController());

  @override
  Widget build(BuildContext context) {
    return BlurScaffold(
      overlayColor: AppColors.blackColor.withAlpha(30),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SafeArea(
              bottom: false,
              child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: SvgPicture.asset(
                    AssetConstants.closeIcon,
                    height: 30,
                  )),
            ),
            hSizedBox10,
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withAlpha(100),
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AppNetworkImage(
                    imageUrl: controller.imageUrl,
                    fit: BoxFit.cover,
                    isOpenImageViewer: true,
                  ),
                ),
              ),
            ),
            hSizedBox30,
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isNotNullOrEmpty(controller.productId)) ...[
                      AppButton(
                        height: 52,
                        width: 52,
                        onTap: () {
                          controller.likedProduct();
                        },
                        gradientBorderColors: AppColors.colorGradient,
                        isOutlined: true,
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: SvgPicture.asset(
                            AssetConstants.heart,
                            height: 28,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                      wSizedBox10
                    ],
                    AppButton(
                      height: 52,
                      width: 170,
                      onTap: () {
                        // Remove QuotationChat controller from memory (Good practice)
                        if (Get.isRegistered<QuotationChatController>()) {
                          Get.delete<QuotationChatController>();
                        }

// Pop any previous instances of the page from the history stack
                        Get.until((route) =>
                            route.settings.name != Routes.quotationChat);

// 🚀 CRITICAL CHANGE: Use Get.offNamed()
// This replaces the current page in the stack with the new one.
                        Get.offNamed(Routes.quotationChat, arguments: {
                          "productId": controller.productId,
                          "imageUrl": controller.imageUrl.split('/').last,
                        });
                      },
                      gradientBorderColors: AppColors.colorGradient,
                      isOutlined: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Get Quote",
                              style: style700S14,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
