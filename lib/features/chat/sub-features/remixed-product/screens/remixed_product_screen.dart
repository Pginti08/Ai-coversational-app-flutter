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
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/features/chat/controller/chat_controller.dart';
import 'package:vousvous/features/chat/sub-features/remixed-product/controller/remixed_product_controller.dart';
import 'package:vousvous/features/chat/sub-features/remixed-product/screens/add_to_post_bottom_sheet.dart';
import 'package:vousvous/features/product-detail/models/check_quotation_exists_model.dart';
import 'package:vousvous/features/quotations/screens/select_body_profile_bottom_sheet.dart';
import 'package:vousvous/features/try-on/utils/tryon_helper.dart';
import 'package:vousvous/routes/app_pages.dart';

class RemixedProductScreen extends StatefulWidget {
  const RemixedProductScreen({super.key});

  @override
  State<RemixedProductScreen> createState() => _RemixedProductScreenState();
}

class _RemixedProductScreenState extends State<RemixedProductScreen> {
  final controller = Get.put(RemixedProductController());
  final RxBool isLoading2 = false.obs;

  Future<void> checkQuotationStatus(BuildContext context) async {
    try {
      isLoading2.value = true;
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.checkQuotationExists}?image=${controller.imageUrl}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        var checkExistsQuotationModel =
            CheckQuotationExistsModel.fromJson(result.data?.data);
        if (checkExistsQuotationModel.data?.exists == true) {
          Get.toNamed(Routes.quotationChat, arguments: {
            "imageUrl": controller.imageUrl,
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
                image: controller.imageUrl,
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

  Future<void> shareGeneratedDesign(String imageUrl) async {
    try {
      if (imageUrl.isEmpty) {
        toast("No design image found");
        return;
      }

      // 1. Read user full name from local storage
      final String fullName =
          LocalStorageService.instance.userInfo.value.data?.name ?? "-";

      // 3. Create product link
      final String customLink =
          'https://vousvous.com/share?refferalCode=${LocalStorageService.instance.userInfo.value.data?.referralCode}&imageUrl=$imageUrl';

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

      final String shareSubject = '✨ Generated Design from Fashion App';

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
      debugPrint("Error sharing generated design: $e");
      toast("Error sharing: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlurScaffold(
      overlayColor: AppColors.blackColor.withAlpha(150),
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
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
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
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CommonContainer(
                          height:
                              34, // Fixed height and width to ensure circular shape
                          width: 34,
                          onTap: () {
                            Get.until(
                                (route) => route.settings.name == Routes.chat);
                            final ChatController chatController =
                                Get.find<ChatController>();
                            chatController.userSelectedRemixOutfits.clear();
                            chatController.userSelectedRemixOutfits.value = [
                              "${controller.imageUrl}"
                            ];
                            chatController.typeFocusNode.requestFocus();
                          },
                          isCircle: true,
                          gradientColors: AppColors.colorGradient,
                          borderColor: AppColors.hintTextColor,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: SvgPicture.asset(
                            AssetConstants.magicpen,
                            color: AppColors.blackColor.withAlpha(150),
                            width: 18,
                          ),
                        ),
                        hSizedBox6,
                        AppButton(
                          onTap: () {
                            openTryOnFlow(
                              context: context,
                              productImageUrl: controller.imageUrl,
                            );
                          },
                          text: "Try On Me",
                          borderColor: AppColors.hintTextColor,
                          textColor: AppColors.blackColor.withAlpha(200),
                          fontSize: 12,
                          height: 34,
                        ),
                      ],
                    ),
                  )
                ],
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
                    Flexible(
                      child: Obx(() => AppButton(
                            height: 52,
                            onTap: () {
                              checkQuotationStatus(context);
                            },
                            gradientBorderColors: AppColors.colorGradient,
                            isOutlined: true,
                            loaderColor: AppColors.whiteColor,
                            isLoading: isLoading2.value,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
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
                    ),
                    wSizedBox8,
                    Flexible(
                      child: AppButton(
                        height: 52,
                        onTap: () {
                          BlurBottomSheet().show<void>(
                            height: MediaQuery.sizeOf(context).height,
                            context: context,
                            borderColor: AppColors.whiteColor.withAlpha(40),
                            backgroundColor:
                                AppColors.scaffoldColor.withAlpha(200),
                            barrierColor: AppColors.blackColor.withAlpha(150),
                            blurStrength: 10,
                            isCloseButton: true,
                            child: AddToPostBottomSheet(
                              imageUrl: controller.imageUrl,
                            ),
                          );
                        },
                        gradientBorderColors: AppColors.colorGradient,
                        isOutlined: true,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // SvgPicture.asset(
                              //   AssetConstants.grid,
                              //   height: 20,
                              // ),
                              // wSizedBox4,
                              Text(
                                "Add To Post",
                                style: style700S14,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    // wSizedBox8,
                    // AppButton(
                    //   height: 52,
                    //   width: 52,
                    //   onTap: () {
                    //     shareGeneratedDesign(fullImageUrl(controller.imageUrl));
                    //   },
                    //   gradientBorderColors: AppColors.colorGradient,
                    //   isOutlined: true,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(15),
                    //     child: SvgPicture.asset(
                    //       AssetConstants.share,
                    //       height: 24,
                    //     ),
                    //   ),
                    // ),
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
