import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/services/local_storage_service.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/app_text_field.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:ai_fashion/core/widgets/custom_image_picker_cropper.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/edit-profile/controller/edit_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});
  final EditProfileController controller = Get.put(EditProfileController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: CustomScaffold(
        resizeToAvoidBottomInset: false,
        isEffect3: true,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Edit Profile',
                          textAlign: TextAlign.center, style: style400S18),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: SvgPicture.asset(AssetConstants.backward),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: ListView(
                    children: [
                      hSizedBox20,
                      Obx(
                        () => Align(
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.blackColor.withOpacity(1),
                                  ),
                                  child: isNotNullOrEmpty(
                                          controller.newProfileImage.value.path)
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          child: Container(
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                            ),
                                            child: Image.file(
                                              controller.newProfileImage.value,
                                              fit: BoxFit.cover,
                                              width: 100,
                                              height: 100,
                                            ),
                                          ),
                                        )
                                      : AppNetworkImage(
                                          imageUrl: LocalStorageService.instance
                                                  .userInfo.value.data?.image ??
                                              "",
                                          shape: BoxShape.circle,
                                          fit: BoxFit.cover,
                                          errorWidget: Container(
                                            width: 100,
                                            height: 100,
                                            color: AppColors.lightGreyTextColor
                                                .withAlpha(30),
                                            padding: EdgeInsets.all(24),
                                            alignment: Alignment.center,
                                            child: SvgPicture.asset(
                                              AssetConstants.user,
                                              color: AppColors.whiteColor,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                child: CommonContainer(
                                    onTap: () {
                                      imagePickerCropper(context, (file) {
                                        controller.newProfileImage.value = file;
                                      });
                                    },
                                    borderRadius: 100,
                                    backgroundColor:
                                        AppColors.greyBackgroundColor,
                                    borderColor: const Color(0xFF414141),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 3),
                                    child: Text(
                                      "Edit",
                                      style: style400S12.copyWith(
                                        color: const Color(0xFF959595),
                                      ),
                                    )),
                              )
                            ],
                          ),
                        ),
                      ),
                      hSizedBox16,
                      Obx(() => AppTextField(
                            label: "Name".toUpperCase(),
                            controller: controller.nameController,
                            isRequired: true,
                            hint: "Enter Name",
                            isGradientBorder: true,
                            fillColor: AppColors.whiteColor.withAlpha(10),
                            hintStyle:
                                style400S16.copyWith(color: Color(0xFF444444)),
                            errorText: controller.nameError.value.isEmpty
                                ? null
                                : controller.nameError.value,
                            onChanged: (value) {
                              if (controller.nameError.value.isNotEmpty) {
                                controller.nameError.value = '';
                              }
                            },
                          )),
                      hSizedBox16,
                      AppTextField(
                        label: "Mobile Number".toUpperCase(),
                        controller: controller.mobileNoController,
                        isRequired: true,
                        hint: "Enter Mobile Number",
                        isGradientBorder: true,
                        fillColor: AppColors.whiteColor.withAlpha(10),
                        readOnly: true,
                        hintStyle:
                            style400S16.copyWith(color: Color(0xFF444444)),
                      ),
                      hSizedBox16,
                      Obx(() => AppTextField(
                            label: "Bio".toUpperCase(),
                            controller: controller.bioController,
                            isRequired: true,
                            hint: "Enter Bio",
                            maxLines: 2,
                            isGradientBorder: true,
                            fillColor: AppColors.whiteColor.withAlpha(10),
                            hintStyle:
                                style400S16.copyWith(color: Color(0xFF444444)),
                            errorText: controller.bioError.value.isEmpty
                                ? null
                                : controller.bioError.value,
                            onChanged: (value) {
                              if (controller.bioError.value.isNotEmpty) {
                                controller.bioError.value = '';
                              }
                            },
                          )),
                      hSizedBox16,
                      CommonContainer(
                        padding:
                            EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        borderRadius: 16,
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        backgroundColor: AppColors.whiteColor.withAlpha(10),
                        borderGradientColors: AppColors.glassBorderGradient,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Private Post",
                                  style: style500S18.copyWith(
                                      color: Color(0xFFEFEFEF),
                                      letterSpacing: 0.36),
                                ),
                                Obx(() => Transform.scale(
                                      scale: 0.75,
                                      child: Switch(
                                        value: controller.isPrivatePost.value,
                                        onChanged: (val) {
                                          controller.isPrivatePost.value = val;
                                        },
                                        padding: EdgeInsets.zero,
                                        activeTrackColor: AppColors.grey2Color,
                                        inactiveTrackColor:
                                            AppColors.grey2Color.withAlpha(150),
                                        trackOutlineColor:
                                            const WidgetStatePropertyAll(
                                                Colors.transparent),
                                        thumbColor: WidgetStateProperty
                                            .resolveWith<Color?>((states) {
                                          if (states
                                              .contains(WidgetState.selected)) {
                                            return Colors.white;
                                          }
                                          return Colors.grey;
                                        }),
                                        thumbIcon:
                                            WidgetStateProperty.all<Icon?>(
                                          const Icon(
                                            Icons.circle,
                                            size: 0,
                                          ),
                                        ),
                                        materialTapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                      ),
                                    ))
                              ],
                            ),
                            hSizedBox6,
                            Text(
                              "Now your post is Private, only the followers you approve can be seen what you post.",
                              style: style300S14.copyWith(
                                  color: Color(0xFF757575),
                                  letterSpacing: 0.28),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => AppButton(
                        onTap: () {
                          controller.validateAndUpdateProfile();
                        },
                        text: "Save Changes",
                        isLoading: controller.isLoading.value ||
                            controller.isLoading2.value,
                      )),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
