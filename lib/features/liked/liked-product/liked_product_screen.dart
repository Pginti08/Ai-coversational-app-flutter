import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/core/widgets/blur_scaffold.dart';
import 'package:vousvous/features/liked/liked-product/controller/liked_product_controller.dart';
import 'package:vousvous/features/product-detail/models/check_quotation_exists_model.dart';
import 'package:vousvous/features/quotations/screens/select_body_profile_bottom_sheet.dart';
import 'package:vousvous/routes/app_pages.dart';

class LikedProductScreen extends StatefulWidget {
  const LikedProductScreen({super.key});

  @override
  State<LikedProductScreen> createState() => _LikedProductScreenState();
}

class _LikedProductScreenState extends State<LikedProductScreen> {
  final controller = Get.put(LikedProductController());
  final RxBool isLoading2 = false.obs;

  Future<void> checkQuotationStatus(BuildContext context) async {
    try {
      isLoading2.value = true;
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.checkQuotationExists}?productId=${controller.productDetail.value.id}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        var checkExistsQuotationModel =
            CheckQuotationExistsModel.fromJson(result.data?.data);
        if (checkExistsQuotationModel.data?.exists == true) {
          Get.toNamed(Routes.quotationChat, arguments: {
            "productId": controller.productDetail.value.id,
            "quotationId": checkExistsQuotationModel.data?.quotationId,
          });
        } else {
          BlurBottomSheet().show<void>(
              height: MediaQuery.sizeOf(context).height * 0.8,
              context: context,
              borderColor: AppColors.whiteColor.withAlpha(40),
              backgroundColor: AppColors.scaffoldColor.withAlpha(230),
              barrierColor: AppColors.blackColor.withAlpha(50),
              blurStrength: 10,
              isCloseButton: true,
              child: SelectBodyProfileBottomSheet(
                productId: controller.productDetail.value.id,
                image: controller.productDetail.value.image,
                aiAnalysis: checkExistsQuotationModel.data?.aiAnalysis,
              ));
        }
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading2.value = false;
    }
  }

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

  Future<void> _shareProduct() async {
    try {
      // 1. Setup Data
      final imageUrl = controller.productDetail.value.image ?? "";
      final productTitle = controller.productDetail.value.title ?? '-';
      final productId = controller.productDetail.value.id ?? '';
      final userName = controller.productDetail.value.username ?? '-';

      // 2. Create Link
      final String customLink =
          'https://vousvous.com/share?refferalCode=${LocalStorageService.instance.userInfo.value.data?.referralCode}&productId=$productId&imageUrl=$imageUrl';

      // 3. Create Message
      final String shareMessage = '''
✨ *${productTitle.toUpperCase()}* ✨

Check out this stunning outfit on *VOUSVOUS*! 👗✨

Designed by: $userName

🎨 Design your dream dress with intelligent styling
🔥 Discover unique fashion creations
💎 Connect with expert designers
🛍️ Get instant quotes effortlessly

Download *VOUSVOUS* now and bring your fashion vision to life!

👉 $customLink

#VOUSVOUS #DreamDress #IntelligentStyling #FashionDesign #StyleInspiration #OOTD
''';

      final String shareSubject =
          '✨ ${productTitle.toUpperCase()} - Fashion App';

      // 4. Prepare Files (if image exists)
      List<XFile> filesToShare = [];

      if (imageUrl.isNotEmpty) {
        final String? imagePath = await _downloadImage(imageUrl);
        if (imagePath != null && imagePath.isNotEmpty) {
          filesToShare.add(XFile(imagePath));
        }
      }

      // 5. Handle iPad Position (Optional but recommended)
      // iPad requires a source rect to anchor the share popup
      final box = context.findRenderObject() as RenderBox?;
      final Rect? shareOrigin =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      // 6. Execute Share using the NEW API
      // "Share.share" and "Share.shareXFiles" are replaced by "SharePlus.instance.share"
      // using a "ShareParams" object.
      await SharePlus.instance.share(
        ShareParams(
          text: shareMessage,
          subject: shareSubject,
          files: filesToShare, // Can be empty for text-only share
          sharePositionOrigin: shareOrigin, // Crucial for iPad
        ),
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
      toast('Error sharing: $e');
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
                    Obx(() => AppButton(
                          height: 52,
                          width: 170,
                          onTap: () {
                            checkQuotationStatus(context);
                          },
                          gradientBorderColors: AppColors.colorGradient,
                          isOutlined: true,
                          isLoading: isLoading2.value,
                          loaderColor: AppColors.whiteColor,
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
                        )),
                    wSizedBox10,
                    AppButton(
                      height: 52,
                      width: 52,
                      onTap: () {
                        _shareProduct();
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
