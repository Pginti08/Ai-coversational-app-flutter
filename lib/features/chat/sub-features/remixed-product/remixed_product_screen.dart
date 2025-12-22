import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/blur_scaffold.dart';
import 'package:vousvous/features/chat/sub-features/remixed-product/controller/remixed_product_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class RemixedProductScreen extends StatefulWidget {
  const RemixedProductScreen({super.key});

  @override
  State<RemixedProductScreen> createState() => _RemixedProductScreenState();
}

class _RemixedProductScreenState extends State<RemixedProductScreen> {
  final controller = Get.put(RemixedProductController());

  // Method to download image and return file path
  Future<String?> _downloadImage(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode == 200) {
        final documentDirectory = await getTemporaryDirectory();
        final file = File('${documentDirectory.path}/shared_product_image.jpg');
        await file.writeAsBytes(response.bodyBytes);
        return file.path;
      }
    } catch (e) {
      print('Error downloading image: $e');
    }
    return null;
  }

  Future<void> shareGeneratedDesign(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) {
        toast("No design image found");
        return;
      }

      // 1. Read user full name from local storage
      final String fullName =
          LocalStorageService.instance.userInfo.value.data?.name ?? "-";

      // 2. Download image
      final String? imagePath = await _downloadImage(imageUrl);

      if (imagePath == null || imagePath.isEmpty) {
        toast("Unable to download design");
        return;
      }

      final XFile fileToShare = XFile(imagePath);

      // 3. Create product link
      final String customLink = 'https://vousvous.com/share?imageUrl=$imageUrl';

      // 4. Create share message - SIMPLIFIED for WhatsApp compatibility
      final String shareMessage = '''✨ Generated Design ✨

Check out this stunning outfit on VOUSVOUS! 👗✨

Designed by: $fullName

🎨 Design your dream dress with intelligent styling
🔥 Discover unique fashion creations
💎 Connect with expert designers
🛍️ Get instant quotes effortlessly

Download VOUSVOUS now and bring your fashion vision to life!

👉 $customLink

#VOUSVOUS #DreamDress #IntelligentStyling #FashionDesign #StyleInspiration #OOTD''';

      // 5. iPad popup position
      final box = context.findRenderObject() as RenderBox?;
      final Rect? shareOrigin =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      // 6. Share with proper parameters for WhatsApp
      await Share.shareXFiles(
        [fileToShare],
        text: shareMessage, // ✅ Text will be caption for image
        subject:
            '✨ Generated Design from Fashion App', // ✅ Subject for email apps
        sharePositionOrigin: shareOrigin,
      );
    } catch (e) {
      debugPrint("Error sharing generated design: $e");
      toast("Error sharing: $e");
    }
  }

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
                      width: 170,
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
                    ),
                    wSizedBox10,
                    AppButton(
                      height: 52,
                      width: 52,
                      onTap: () {
                        shareGeneratedDesign(fullImageUrl(controller.imageUrl));
                      },
                      gradientBorderColors: AppColors.colorGradient,
                      isOutlined: true,
                      child: Padding(
                        padding: const EdgeInsets.all(15),
                        child: SvgPicture.asset(
                          AssetConstants.share,
                          height: 24,
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
