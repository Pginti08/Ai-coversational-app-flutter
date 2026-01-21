import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/common_dialog.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/body-profile/controller/body_profile_controller.dart';
import 'package:vousvous/features/body-profile/screens/body_profile_type_bottom_sheet.dart';
import 'package:vousvous/features/body-profile/screens/scanned_manually_bottom_sheet.dart';

class BodyProfileScreen extends StatelessWidget {
  BodyProfileScreen({super.key});
  final BodyProfileController controller = Get.put(BodyProfileController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isBottomEffect: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Body Profiles'.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: style700S14.copyWith(
                            letterSpacing: 0.96, color: Color(0xFFCCCCCC))),
                  ],
                ),
                Positioned(
                  left: 0,
                  child: IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: SvgPicture.asset(
                      AssetConstants.backward,
                      height: 24,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    hSizedBox18,
                    AppButton(
                      isOutlined: true,
                      isGradientBorder: true,
                      onTap: () {
                        BlurBottomSheet().show<void>(
                          height: MediaQuery.sizeOf(context).height * 0.2,
                          context: context,
                          borderColor: AppColors.whiteColor.withAlpha(
                            40,
                          ),
                          backgroundColor:
                              AppColors.scaffoldColor.withAlpha(200),
                          barrierColor: AppColors.blackColor.withAlpha(50),
                          blurStrength: 30,
                          isCloseButton: true,
                          child: BodyProfileTypeBottomSheet(),
                        );
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
                            style:
                                style700S16.copyWith(color: Color(0xFFCCCCCC)),
                          )
                        ],
                      ),
                    ),
                    hSizedBox40,
                    Expanded(
                      child: Obx(
                        () => controller.isLoading.value
                            ? Center(
                                child: RotatingLoader(),
                              )
                            : (controller.savedBodyProfileModel.value.data
                                            ?.length ??
                                        0) ==
                                    0
                                ? Center(
                                    child: Text(
                                      "Empty Saved Body Profiles",
                                      style: style400S14,
                                    ),
                                  )
                                : ListView.separated(
                                    itemCount: controller.savedBodyProfileModel
                                            .value.data?.length ??
                                        0,
                                    separatorBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 14),
                                        child: Divider(
                                          color: AppColors.grey2Color,
                                        ),
                                      );
                                    },
                                    itemBuilder: (context, index) {
                                      return Row(
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
                                                        controller
                                                                .savedBodyProfileModel
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
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 8),
                                                  borderRadius: 100,
                                                  borderGradientColors:
                                                      AppColors
                                                          .glassBorderGradient,
                                                  child: Text(
                                                    "${controller.savedBodyProfileModel.value.data?[index].height?.toStringAsFixed(0) ?? '0'} ${(controller.savedBodyProfileModel.value.data?[index].unit ?? "").toUpperCase()}  •  ${controller.savedBodyProfileModel.value.data?[index].bust?.toStringAsFixed(0) ?? '0'}” | ${controller.savedBodyProfileModel.value.data?[index].waist?.toStringAsFixed(0) ?? '0'}” | ${controller.savedBodyProfileModel.value.data?[index].hips?.toStringAsFixed(0) ?? '0'}” | ${controller.savedBodyProfileModel.value.data?[index].shoulders?.toStringAsFixed(0) ?? '0'}”"
                                                        .toUpperCase(),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: style700S12.copyWith(
                                                        letterSpacing: 0.96,
                                                        color:
                                                            Color(0xFFCCCCCC)),
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
                                                      height: MediaQuery.sizeOf(
                                                                  context)
                                                              .height *
                                                          0.7,
                                                      context: context,
                                                      borderColor: AppColors
                                                          .whiteColor
                                                          .withAlpha(
                                                        40,
                                                      ),
                                                      backgroundColor: AppColors
                                                          .scaffoldColor,
                                                      barrierColor: AppColors
                                                          .blackColor
                                                          .withAlpha(50),
                                                      blurStrength: 30,
                                                      isCloseButton: true,
                                                      child: ScannedManuallyBottomSheet(
                                                          isEdit: true,
                                                          savedBodyProfile:
                                                              controller
                                                                  .savedBodyProfileModel
                                                                  .value
                                                                  .data?[index]),
                                                    );
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
                                                          controller
                                                              .deleteSavedBodyProfile(
                                                                  controller
                                                                      .savedBodyProfileModel
                                                                      .value
                                                                      .data?[
                                                                          index]
                                                                      .id);
                                                        },
                                                        isLoading: controller
                                                            .isLoading2);
                                                  },
                                                  child: SvgPicture.asset(
                                                      AssetConstants.remove))
                                            ],
                                          )
                                        ],
                                      );
                                    },
                                  ),
                      ),
                    ),
                    hSizedBox10,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
