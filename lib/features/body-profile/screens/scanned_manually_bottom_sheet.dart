import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/utils/validators.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_text_field.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/features/body-profile/controller/body_profile_controller.dart';
import 'package:vousvous/features/body-profile/models/saved_body_profile_model.dart';

class ScannedManuallyBottomSheet extends StatefulWidget {
  ScannedManuallyBottomSheet(
      {super.key, this.isEdit = false, this.savedBodyProfile, this.onSave});
  final bool isEdit;
  final SavedBodyProfile? savedBodyProfile;
  final void Function(dynamic)? onSave;

  @override
  State<ScannedManuallyBottomSheet> createState() =>
      _ScannedManuallyBottomSheetState();
}

class _ScannedManuallyBottomSheetState
    extends State<ScannedManuallyBottomSheet> {
  final RxBool isLoading = false.obs;

  final TextEditingController nameController = TextEditingController();

  final TextEditingController heightController = TextEditingController();

  final TextEditingController bustController = TextEditingController();

  final TextEditingController waistController = TextEditingController();

  final TextEditingController hipController = TextEditingController();

  final TextEditingController shoulderController = TextEditingController();

  final RxString nameError = ''.obs;

  final RxString heightError = ''.obs;

  final RxString bustError = ''.obs;

  final RxString waistError = ''.obs;

  final RxString hipError = ''.obs;

  final RxString shoulderError = ''.obs;

  @override
  void initState() {
    nameController.text = widget.savedBodyProfile?.name ?? "";
    heightController.text =
        (widget.savedBodyProfile?.height?.toInt() ?? "").toString();
    bustController.text =
        (widget.savedBodyProfile?.bust?.toInt() ?? "").toString();
    waistController.text =
        (widget.savedBodyProfile?.waist?.toInt() ?? "").toString();
    hipController.text =
        (widget.savedBodyProfile?.hips?.toInt() ?? "").toString();
    shoulderController.text =
        (widget.savedBodyProfile?.shoulders?.toInt() ?? "").toString();

    super.initState();
  }

  void validateAndSave() {
    final error1 = validateCommonField(nameController.text.trim(), "name");
    final error2 =
        validateMeasurementField(heightController.text.trim(), "height");
    final error3 = validateMeasurementField(bustController.text.trim(), "bust");
    final error4 =
        validateMeasurementField(waistController.text.trim(), "waist");
    final error5 = validateMeasurementField(hipController.text.trim(), "hip");
    final error6 =
        validateMeasurementField(shoulderController.text.trim(), "shoulder");

    nameError.value = error1 ?? '';
    heightError.value = error2 ?? '';
    bustError.value = error3 ?? '';
    waistError.value = error4 ?? '';
    hipError.value = error5 ?? '';
    shoulderError.value = error6 ?? '';

    if (error1 == null &&
        error2 == null &&
        error3 == null &&
        error4 == null &&
        error5 == null &&
        error6 == null) {
      // Create JSON string from current field values
      final Map<String, dynamic> bodyProfileMap = {
        "name": nameController.text.trim(),
        "height": int.tryParse(heightController.text.trim()) ?? 0,
        "heightUnit": "CM",
        "bust": int.tryParse(bustController.text.trim()) ?? 0,
        "bustUnit": "CM",
        "waist": int.tryParse(waistController.text.trim()) ?? 0,
        "waistUnit": "CM",
        "hips": int.tryParse(hipController.text.trim()) ?? 0,
        "hipsUnit": "CM",
        "shoulders": int.tryParse(shoulderController.text.trim()) ?? 0,
        "shouldersUnit": "CM",
      };

      final String jsonString = json.encode(bodyProfileMap);

      // Pass the JSON string via onSave callback
      widget.onSave?.call(jsonString);

      // If no onSave provided, fallback to API call
      if (widget.onSave == null) {
        saveBodyProfileApi();
      }
    }
  }

  Future<void> saveBodyProfileApi() async {
    try {
      isLoading.value = true;

      var result = await NetworkClient.instance.callApi(
          widget.isEdit
              ? "${ApiConstants.bodyProfiles}/${widget.savedBodyProfile?.id}"
              : "${ApiConstants.bodyProfiles}",
          widget.isEdit ? MethodType.patch : MethodType.post,
          baseUrlType: BaseUrl.base,
          params: {
            "name": nameController.text.trim(),
            "height": int.tryParse(heightController.text.trim()),
            "bust": int.tryParse(bustController.text.trim()),
            "waist": int.tryParse(waistController.text.trim()),
            "hips": int.tryParse(hipController.text.trim()),
            "shoulders": int.tryParse(shoulderController.text.trim()),
            "unit": "CM"
          });

      if (result.isSuccess) {
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        if (Get.isRegistered<BodyProfileController>()) {
          Get.find<BodyProfileController>().getSavedBodyProfile();
        }
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
      child: Obx(() => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              children: [
                Text(
                  "Body Profile".toUpperCase(),
                  style: style700S12.copyWith(
                      letterSpacing: 0.96, color: Color(0xFFCCCCCC)),
                ),
                hSizedBox16,
                AppTextField(
                  label: "Name".toUpperCase(),
                  controller: nameController,
                  isRequired: true,
                  hint: "Enter Name",
                  isGradientBorder: true,
                  fillColor: AppColors.whiteColor.withAlpha(12),
                  hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                  errorText: nameError.value.isEmpty ? null : nameError.value,
                  onChanged: (value) {
                    if (nameError.value.isNotEmpty) {
                      nameError.value = '';
                    }
                  },
                ),
                hSizedBox24,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Measurements".toUpperCase(),
                    style: style700S12.copyWith(
                        letterSpacing: 0.96, color: Color(0xFFCCCCCC)),
                  ),
                ),
                hSizedBox10,
                Expanded(
                    child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    measurementsTextField(
                        title: "Height",
                        unit: "CM",
                        textEditingController: heightController,
                        fieldError: heightError),
                    hSizedBox18,
                    measurementsTextField(
                        title: "Bust",
                        unit: "CM",
                        textEditingController: bustController,
                        fieldError: bustError),
                    hSizedBox18,
                    measurementsTextField(
                        title: "Waist",
                        unit: "CM",
                        textEditingController: waistController,
                        fieldError: waistError),
                    hSizedBox18,
                    measurementsTextField(
                        title: "Hips",
                        unit: "CM",
                        textEditingController: hipController,
                        fieldError: hipError),
                    hSizedBox18,
                    measurementsTextField(
                        title: "Shoulders",
                        unit: "CM",
                        textEditingController: shoulderController,
                        fieldError: shoulderError),
                    hSizedBox18,
                  ],
                )),
                hSizedBox10,
                KeyboardVisibilityBuilder(
                    builder: (context, isKeyboardVisible) {
                  return isKeyboardVisible
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8.0),
                          child: SafeArea(
                              top: false,
                              child: Obx(() => AppButton(
                                    text: "Save Body Profile",
                                    isLoading: isLoading.value,
                                    onTap: () {
                                      validateAndSave();
                                    },
                                  ))));
                })
              ],
            ),
          )),
    );
  }

  Widget measurementsTextField({
    required String title,
    required String unit,
    required TextEditingController textEditingController,
    required RxString fieldError,
  }) {
    final FocusNode focusNode = FocusNode(); // FocusNode for this field

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            focusNode.requestFocus(); // Focus the TextField when row is tapped
          },
          child: CommonContainer(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            backgroundColor: AppColors.whiteColor.withAlpha(12),
            borderGradientColors: AppColors.glassBorderGradient,
            borderRadius: 100,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: style700S12.copyWith(
                      letterSpacing: 0.96,
                      color: const Color(0xFF666666),
                    ),
                  ),
                ),
                SizedBox(
                  width: 50,
                  child: AppTextField(
                    focusNode: focusNode, // Assign FocusNode here
                    contentPadding: EdgeInsets.all(0),
                    outsideMargin: const EdgeInsets.symmetric(vertical: 10),
                    textAlign: TextAlign.end,
                    borderColor: Colors.transparent,
                    controller: textEditingController,
                    maxLength: 3,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textStyle: style600S20.copyWith(
                        letterSpacing: 0.42, color: AppColors.whiteTextColor),
                    onChanged: (value) {
                      if (fieldError.value.isNotEmpty) {
                        fieldError.value = '';
                      }
                    },
                  ),
                ),
                Text(
                  unit.toUpperCase(),
                  style: style700S12.copyWith(
                      fontSize: 10,
                      letterSpacing: 0.80,
                      color: const Color(0xFF666666)),
                ),
              ],
            ),
          ),
        ),
        if (isNotNullOrEmpty(fieldError.value))
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 16),
            child: Text(
              fieldError.value,
              style: style300S12.copyWith(color: AppColors.redColor),
            ),
          ),
      ],
    );
  }
}
