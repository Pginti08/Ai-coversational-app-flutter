import 'package:flutter/material.dart';
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
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/common_dialog.dart';
import 'package:vousvous/core/widgets/custom_radio.dart';
import 'package:vousvous/features/body-profile/models/saved_body_profile_model.dart';
import 'package:vousvous/features/body-profile/screens/body_profile_type_bottom_sheet.dart';
import 'package:vousvous/features/body-profile/screens/scanned_manually_bottom_sheet.dart';
import 'package:vousvous/features/product-detail/models/check_quotation_exists_model.dart';
import 'package:vousvous/routes/app_pages.dart';

class SelectBodyProfileBottomSheet extends StatefulWidget {
  SelectBodyProfileBottomSheet(
      {super.key, this.image, this.productId, this.aiAnalysis});
  final String? image;
  final String? productId;
  final AiAnalysis? aiAnalysis;

  @override
  State<SelectBodyProfileBottomSheet> createState() =>
      _SelectBodyProfileBottomSheetState();
}

class _SelectBodyProfileBottomSheetState
    extends State<SelectBodyProfileBottomSheet> {
  final RxBool isLoading = false.obs;
  final RxBool isLoading2 = false.obs;
  final RxBool isLoading3 = false.obs;

  Rxn<SavedBodyProfile> selectedProfile = Rxn();
  final Rx<SavedBodyProfileModel> savedBodyProfileModel =
      SavedBodyProfileModel().obs;

  @override
  void initState() {
    super.initState();

    getSavedBodyProfile();
  }

  Future<void> getSavedBodyProfile() async {
    try {
      isLoading.value = true;
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.bodyProfiles}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        savedBodyProfileModel.value =
            SavedBodyProfileModel.fromJson(result.data?.data);
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSavedBodyProfile(String? id) async {
    try {
      isLoading2.value = true;
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.bodyProfiles}/$id",
        MethodType.delete,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        getSavedBodyProfile();
        selectedProfile.value = null;
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading2.value = false;
    }
  }

  Future<void> createNewQuotation() async {
    try {
      isLoading3.value = true;
      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.createQuotation}", MethodType.post,
          baseUrlType: BaseUrl.base,
          params: {
            if (isNotNullOrEmpty(widget.productId))
              "productId": widget.productId,
            "image": widget.image,
            "bodyProfileId": selectedProfile.value?.id,
            "analysisData": {
              "title": widget.aiAnalysis?.title,
              "description": widget.aiAnalysis?.description,
              "material": widget.aiAnalysis?.material,
              "color": widget.aiAnalysis?.color,
              "type": widget.aiAnalysis?.type,
            },
          });

      if (result.isSuccess) {
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        Get.toNamed(Routes.quotationChat, arguments: {
          "quotationId": result.data?.data["data"]["quotationId"],
          if (isNotNullOrEmpty(widget.productId))
            "productId": widget.productId
          else
            "imageUrl": widget.image,
        });
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading3.value = false;
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
              "Select Body Profile".toUpperCase(),
              style: style700S12.copyWith(
                letterSpacing: 0.96,
                color: Color(0xFFCCCCCC),
              ),
            ),

            hSizedBox18,
            AppButton(
              isOutlined: true,
              isGradientBorder: true,
              onTap: () {
                BlurBottomSheet()
                    .show<void>(
                  height: MediaQuery.sizeOf(context).height * 0.2,
                  context: context,
                  borderColor: AppColors.whiteColor.withAlpha(
                    40,
                  ),
                  backgroundColor: AppColors.scaffoldColor,
                  barrierColor: AppColors.blackColor.withAlpha(50),
                  blurStrength: 10,
                  isCloseButton: true,
                  child: BodyProfileTypeBottomSheet(),
                )
                    .then((val) {
                  getSavedBodyProfile();
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    AssetConstants.add,
                    width: 20,
                  ),
                  wSizedBox8,
                  Text(
                    "Add New",
                    style: style700S16.copyWith(color: Color(0xFFCCCCCC)),
                  )
                ],
              ),
            ),
            hSizedBox40,
            // Body Profile List
            Expanded(
              child: Obx(
                () => isLoading.value
                    ? Center(
                        child: RotatingLoader(),
                      )
                    : (savedBodyProfileModel.value.data?.length ?? 0) == 0
                        ? Center(
                            child: Text(
                              "Empty Saved Body Profiles",
                              style: style400S14,
                            ),
                          )
                        : ListView.separated(
                            itemCount:
                                savedBodyProfileModel.value.data?.length ?? 0,
                            separatorBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Divider(
                                  color: AppColors.grey2Color,
                                ),
                              );
                            },
                            itemBuilder: (context, index) {
                              var bodyProfile =
                                  savedBodyProfileModel.value.data?[index];
                              return Obx(() => CommonContainer(
                                    padding: EdgeInsets.all(8),
                                    borderRadius: 16,
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    borderGradientColors:
                                        selectedProfile.value == bodyProfile
                                            ? AppColors.colorGradient
                                            : null,
                                    gradientColors:
                                        selectedProfile.value == bodyProfile
                                            ? [
                                                Color(0xFF68C3E7).withAlpha(30),
                                                Color(0xFFFFB86B).withAlpha(30),
                                              ]
                                            : null,
                                    child: CustomRadio<SavedBodyProfile?>(
                                        value: savedBodyProfileModel
                                            .value.data?[index],
                                        groupValue: selectedProfile.value,
                                        onChanged: (val) {
                                          selectedProfile.value = val;
                                        },
                                        titleWidget: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      SvgPicture.asset(
                                                          AssetConstants.user2),
                                                      wSizedBox10,
                                                      Expanded(
                                                        child: Text(
                                                          savedBodyProfileModel
                                                                  .value
                                                                  .data?[index]
                                                                  .name ??
                                                              "",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: style500S18
                                                              .copyWith(
                                                            letterSpacing: 0.36,
                                                            color: const Color(
                                                                0xFFEFEFEF),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  hSizedBox16,
                                                  CommonContainer(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 10,
                                                            vertical: 8),
                                                    borderRadius: 100,
                                                    borderGradientColors:
                                                        AppColors
                                                            .glassBorderGradient,
                                                    child: Text(
                                                      "${savedBodyProfileModel.value.data?[index].height?.toStringAsFixed(0) ?? '0'} ${(savedBodyProfileModel.value.data?[index].unit ?? "").toUpperCase()}  •  ${savedBodyProfileModel.value.data?[index].bust?.toStringAsFixed(0) ?? '0'}” | ${savedBodyProfileModel.value.data?[index].waist?.toStringAsFixed(0) ?? '0'}” | ${savedBodyProfileModel.value.data?[index].hips?.toStringAsFixed(0) ?? '0'}” | ${savedBodyProfileModel.value.data?[index].shoulders?.toStringAsFixed(0) ?? '0'}”"
                                                          .toUpperCase(),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style:
                                                          style700S12.copyWith(
                                                              letterSpacing:
                                                                  0.96,
                                                              color: Color(
                                                                  0xFFCCCCCC)),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                IconButton(
                                                    onPressed: () {
                                                      BlurBottomSheet()
                                                          .show<void>(
                                                        height:
                                                            MediaQuery.sizeOf(
                                                                        context)
                                                                    .height *
                                                                0.7,
                                                        context: context,
                                                        borderColor: AppColors
                                                            .whiteColor
                                                            .withAlpha(
                                                          40,
                                                        ),
                                                        backgroundColor:
                                                            AppColors
                                                                .scaffoldColor,
                                                        barrierColor: AppColors
                                                            .blackColor
                                                            .withAlpha(50),
                                                        blurStrength: 10,
                                                        isCloseButton: true,
                                                        child: ScannedManuallyBottomSheet(
                                                            isEdit: true,
                                                            savedBodyProfile:
                                                                savedBodyProfileModel
                                                                        .value
                                                                        .data?[
                                                                    index]),
                                                      )
                                                          .then((val) {
                                                        getSavedBodyProfile();
                                                      });
                                                    },
                                                    icon: SvgPicture.asset(
                                                        AssetConstants.edit)),
                                                CommonContainer(
                                                    isCircle: true,
                                                    borderGradientColors:
                                                        AppColors
                                                            .glassBorderGradient,
                                                    padding: EdgeInsets.all(8),
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    onTap: () {
                                                      commonDialog(
                                                          title:
                                                              "Delete Saved Body Profile?",
                                                          description:
                                                              "Are you sure you want to delete this permanently?",
                                                          successButtonTitle:
                                                              "Delete",
                                                          cancelButtonTitle:
                                                              "Cancel",
                                                          onSuccess: () {
                                                            deleteSavedBodyProfile(
                                                                savedBodyProfileModel
                                                                    .value
                                                                    .data?[
                                                                        index]
                                                                    .id);
                                                          },
                                                          isLoading:
                                                              isLoading2);
                                                    },
                                                    child: SvgPicture.asset(
                                                        AssetConstants.remove))
                                              ],
                                            )
                                          ],
                                        )),
                                  ));
                            },
                          ),
              ),
            ),

            hSizedBox16,

            // Confirm Button
            Obx(() => AppButton(
                  onTap: () {
                    if (selectedProfile.value != null) {
                      createNewQuotation();
                    } else {
                      toast("Please select body profile");
                    }
                  },
                  isLoading: isLoading2.value,
                  child: Text(
                    "Confirm Selection",
                    style: style700S16.copyWith(color: Colors.black),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
