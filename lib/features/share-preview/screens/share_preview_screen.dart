import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/core/widgets/blur_scaffold.dart';
import 'package:vousvous/features/product-detail/models/check_quotation_exists_model.dart';
import 'package:vousvous/features/quotation-chat/controller/quotation_chat_controller.dart'
    show QuotationChatController;
import 'package:vousvous/features/quotations/screens/select_body_profile_bottom_sheet.dart';
import 'package:vousvous/features/share-preview/controller/share_preview_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class SharePreviewScreen extends StatefulWidget {
  const SharePreviewScreen({super.key});

  @override
  State<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends State<SharePreviewScreen> {
  final controller = Get.put(SharePreviewController());

  final RxBool isLoading2 = false.obs;

  Future<void> checkQuotationStatus(BuildContext context) async {
    try {
      isLoading2.value = true;
      var result = await NetworkClient.instance.callApi(
        isNotNullOrEmpty(controller.productId)
            ? "${ApiConstants.checkQuotationExists}?productId=${controller.productId}"
            : "${ApiConstants.checkQuotationExists}?image=${controller.imageUrl}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        var checkExistsQuotationModel =
            CheckQuotationExistsModel.fromJson(result.data?.data);
        if (checkExistsQuotationModel.data?.exists == true) {
          // 1️⃣ Remove controller
          if (Get.isRegistered<QuotationChatController>()) {
            Get.delete<QuotationChatController>();
          }

// 2️⃣ Pop until no quotationChat exists in stack
          while (Get.routing.route?.settings.name == Routes.quotationChat) {
            Get.back();
          }

// 3️⃣ Push fresh quotation chat
          await Future.delayed(
              Duration(milliseconds: 100)); // Give time to clean up
          Get.toNamed(
            Routes.quotationChat,
            arguments: {
              "productId": controller.productId,
              "imageUrl": controller.imageUrl,
              "quotationId": checkExistsQuotationModel.data?.quotationId,
            },
            preventDuplicates: false,
          );
        } else {
          BlurBottomSheet().show<void>(
              height: MediaQuery.sizeOf(context).height * 0.8,
              context: context,
              borderColor: AppColors.whiteColor.withAlpha(40),
              backgroundColor: AppColors.scaffoldColor,
              barrierColor: AppColors.blackColor.withAlpha(50),
              blurStrength: 30,
              isCloseButton: true,
              child: SelectBodyProfileBottomSheet(
                productId: controller.productId,
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
                    Obx(() => AppButton(
                          height: 52,
                          width: 170,
                          onTap: () {
                            checkQuotationStatus(context);
                          },
                          isLoading: isLoading2.value,
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
                        )),
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
