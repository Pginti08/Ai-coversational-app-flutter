import 'dart:io';

import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/core/widgets/blur_bottom_sheet.dart';
import 'package:ai_fashion/core/widgets/bullet_point_list.dart';
import 'package:ai_fashion/core/widgets/custom_image_picker_cropper.dart';
import 'package:ai_fashion/features/body-profile/models/ai_body_profile_detect_model.dart';
import 'package:ai_fashion/features/body-profile/models/saved_body_profile_model.dart';
import 'package:ai_fashion/features/body-profile/screens/scanned_manually_bottom_sheet.dart';
import 'package:dio/dio.dart' as dio;
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ScanWithAiBottomSheet extends StatelessWidget {
  ScanWithAiBottomSheet({super.key, this.onSave});
  final void Function(dynamic)? onSave;

  final RxBool isLoading = false.obs;
  final Rxn<File> frontImage = Rxn<File>();
  final Rxn<File> backImage = Rxn<File>();
  final Rxn<File> sideImage = Rxn<File>();

  Future<void> bodyMeasurementsAnalyzeApi(BuildContext context) async {
    try {
      isLoading.value = true;
      var result = await NetworkClient.instance
          .callApi("${ApiConstants.bodyMeasurementsAnalyze}", MethodType.post,
              baseUrlType: BaseUrl.chat,
              headers: {"Content-Type": "multipart/form-data"},
              params: dio.FormData.fromMap({
                'front_image': dio.MultipartFile.fromFileSync(
                  frontImage.value!.path,
                  filename: frontImage.value!.path.split('/').last,
                  contentType: dio.DioMediaType("image", "png"),
                ),
                'back_image': dio.MultipartFile.fromFileSync(
                  backImage.value!.path,
                  filename: backImage.value!.path.split('/').last,
                  contentType: dio.DioMediaType("image", "png"),
                ),
                'side_image': dio.MultipartFile.fromFileSync(
                  sideImage.value!.path,
                  filename: sideImage.value!.path.split('/').last,
                  contentType: dio.DioMediaType("image", "png"),
                )
              }));

      if (result.isSuccess) {
        var aiBodyProfileDetectModel =
            AiBodyProfileDetectModel.fromJson(result.data?.data);
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        BlurBottomSheet().show<void>(
          height: MediaQuery.sizeOf(context).height * 0.7,
          context: context,
          borderColor: AppColors.whiteColor.withAlpha(
            40,
          ),
          backgroundColor: AppColors.scaffoldColor,
          barrierColor: AppColors.blackColor.withAlpha(50),
          blurStrength: 30,
          isCloseButton: true,
          child: ScannedManuallyBottomSheet(
            savedBodyProfile: SavedBodyProfile(
              height: aiBodyProfileDetectModel.measurements?.height,
              bust: aiBodyProfileDetectModel.measurements?.bust,
              waist: aiBodyProfileDetectModel.measurements?.waist,
              hips: aiBodyProfileDetectModel.measurements?.hips,
              shoulders: aiBodyProfileDetectModel.measurements?.shoulders,
              unit: "CM",
            ),
            onSave: onSave,
          ),
        );
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Text(
              "Scan with AI".toUpperCase(),
              style: style700S12.copyWith(
                  letterSpacing: 0.96, color: Color(0xFFCCCCCC)),
            ),
            hSizedBox20,
            Row(
              children: [
                Expanded(child: Image.asset(AssetConstants.frontBody)),
                wSizedBox10,
                Expanded(child: Image.asset(AssetConstants.sideBody)),
                wSizedBox10,
                Expanded(child: Image.asset(AssetConstants.backBody)),
              ],
            ),
            hSizedBox12,
            SizedBox(
              height: 140,
              child: Obx(
                () => Row(
                  children: [
                    Expanded(
                        child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: const Color(0xFF666666),
                        dashPattern: const [8, 4],
                        radius: const Radius.circular(14),
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          imagePickerCropper((file) {
                            frontImage.value = file;
                          });
                        },
                        child: isNotNullOrEmpty(frontImage.value)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 140,
                                  child: Image.file(
                                    frontImage.value!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Container(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(AssetConstants.add),
                                    hSizedBox10,
                                    Text(
                                      "Front",
                                      style: style700S16.copyWith(
                                          color: Color(0xFFCCCCCC)),
                                    )
                                  ],
                                ),
                              ),
                      ),
                    )),
                    wSizedBox10,
                    Expanded(
                        child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: const Color(0xFF666666),
                        dashPattern: const [8, 4],
                        radius: const Radius.circular(14),
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          imagePickerCropper((file) {
                            sideImage.value = file;
                          });
                        },
                        child: isNotNullOrEmpty(sideImage.value)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 140,
                                  child: Image.file(
                                    sideImage.value!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Container(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(AssetConstants.add),
                                    hSizedBox10,
                                    Text(
                                      "Side",
                                      style: style700S16.copyWith(
                                          color: Color(0xFFCCCCCC)),
                                    )
                                  ],
                                ),
                              ),
                      ),
                    )),
                    wSizedBox10,
                    Expanded(
                        child: DottedBorder(
                      options: RoundedRectDottedBorderOptions(
                        color: const Color(0xFF666666),
                        dashPattern: const [8, 4],
                        radius: const Radius.circular(14),
                      ),
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          imagePickerCropper((file) {
                            backImage.value = file;
                          });
                        },
                        child: isNotNullOrEmpty(backImage.value)
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 140,
                                  child: Image.file(
                                    backImage.value!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            : Container(
                                alignment: Alignment.center,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(AssetConstants.add),
                                    hSizedBox10,
                                    Text(
                                      "Back",
                                      style: style700S16.copyWith(
                                          color: Color(0xFFCCCCCC)),
                                    )
                                  ],
                                ),
                              ),
                      ),
                    ))
                  ],
                ),
              ),
            ),
            hSizedBox10,
            BulletPointList(items: const [
              "Front full-body image",
              "Side full-body image",
              "Back full-body image",
              "Good lighting is essential",
              "Use a neutral background"
            ]),
            Spacer(),
            Obx(() => AppButton(
                  isOutlined: true,
                  isGradientBorder: true,
                  backgroundColor: AppColors.whiteColor.withAlpha(10),
                  loaderColor: AppColors.whiteColor,
                  isLoading: isLoading.value,
                  text: "Proceed to Scan",
                  textColor: const Color(0xFFCCCCCC),
                  onTap: () {
                    if (frontImage.value != null &&
                        backImage.value != null &&
                        sideImage.value != null) {
                      bodyMeasurementsAnalyzeApi(context);
                    } else {
                      toast('Please select all required images');
                    }
                  },
                )),
          ],
        ),
      ),
    );
  }
}
