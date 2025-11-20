import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_text_field.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/invite-friend/controller/invite_friend_controller.dart';

class InviteFriendScreen extends StatelessWidget {
  InviteFriendScreen({super.key});
  final InviteFriendController controller = Get.put(InviteFriendController());

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
          padding: EdgeInsets.only(top: Platform.isAndroid ? 6 : 0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Invite Friend',
                        textAlign: TextAlign.center,
                        style:
                            style700S28.copyWith(color: AppColors.textColor)),
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: SvgPicture.asset(AssetConstants.closeIcon),
                    )
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: ListView(
                    children: [
                      hSizedBox20,
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
                      hSizedBox20,
                      Obx(() => AppTextField(
                            label: "Mobile Number".toUpperCase(),
                            controller: controller.mobileNoController,
                            isRequired: true,
                            hint: "Enter Mobile Number",
                            isGradientBorder: true,
                            fillColor: AppColors.whiteColor.withAlpha(10),
                            hintStyle:
                                style400S16.copyWith(color: Color(0xFF444444)),
                            maxLength: 10,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            prefixIcon: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('🇮🇳+91', style: style400S16),
                                hSizedBox2,
                              ],
                            ),
                            errorText: controller.mobileError.value.isEmpty
                                ? null
                                : controller.mobileError.value,
                            onChanged: (value) {
                              if (controller.mobileError.value.isNotEmpty) {
                                controller.mobileError.value = '';
                              }
                            },
                          )),
                      hSizedBox20,
                      Obx(() => AppTextField(
                            label: "Email".toUpperCase(),
                            controller: controller.emailController,
                            hint: "Enter Email",
                            isGradientBorder: true,
                            fillColor: AppColors.whiteColor.withAlpha(10),
                            hintStyle:
                                style400S16.copyWith(color: Color(0xFF444444)),
                            errorText: controller.emailError.value.isEmpty
                                ? null
                                : controller.emailError.value,
                            onChanged: (value) {
                              if (controller.emailError.value.isNotEmpty) {
                                controller.emailError.value = '';
                              }
                            },
                          )),
                      hSizedBox16,
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => AppButton(
                        onTap: () {
                          controller.validateAndInviteFriend();
                        },
                        text: "Invite Friend",
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
