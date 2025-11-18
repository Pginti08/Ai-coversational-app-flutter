import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/blur_scaffold.dart';
import 'package:ai_fashion/features/chat/sub-features/remixed-product/controller/remixed_product_controller.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class RemixedProductScreen extends StatefulWidget {
  const RemixedProductScreen({super.key});

  @override
  State<RemixedProductScreen> createState() => _RemixedProductScreenState();
}

class _RemixedProductScreenState extends State<RemixedProductScreen> {
  final controller = Get.put(RemixedProductController());
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
                    AppButton(
                      height: 52,
                      width: 170.w,
                      onTap: () {
                        Get.toNamed(Routes.quotationChat, arguments: {
                          "imageUrl": controller.imageUrl,
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
                    )
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
