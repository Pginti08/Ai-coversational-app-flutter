import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/utils/validators.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_text_field.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/features/saved-address/models/saved_address_model.dart';
import 'package:vousvous/features/saved-address/screens/city_list_bottom_sheet.dart';
import 'package:vousvous/features/saved-address/screens/state_list_bottom_sheet.dart';
import 'package:vousvous/features/saved-address/services/pincode_service.dart';

class AddAddressBottomSheet extends StatefulWidget {
  final bool isEdit;
  final SavedAddress? savedAddress;
  final VoidCallback? onSuccess; // ✅ Add callback

  const AddAddressBottomSheet({
    super.key,
    this.isEdit = false,
    this.savedAddress,
    this.onSuccess,
  });

  @override
  State<AddAddressBottomSheet> createState() => _AddAddressBottomSheetState();
}

class _AddAddressBottomSheetState extends State<AddAddressBottomSheet> {
  final RxBool isLoading = false.obs;
  final RxBool isPincodeLoading = false.obs;

  final TextEditingController nameController = TextEditingController();

  final TextEditingController mobileNoController = TextEditingController();

  final TextEditingController pincodeController = TextEditingController();

  final TextEditingController addressController = TextEditingController();

  final TextEditingController stateController = TextEditingController();

  final TextEditingController cityController = TextEditingController();

  final RxString nameError = ''.obs;

  final RxString mobileError = ''.obs;

  final RxString pincodeError = ''.obs;

  final RxString addressError = ''.obs;

  final RxString stateError = ''.obs;

  final RxString cityError = ''.obs;

  @override
  void initState() {
    nameController.text = widget.savedAddress?.name ?? "";
    mobileNoController.text =
        (widget.savedAddress?.mobile ?? "").split(" ").last;
    pincodeController.text = widget.savedAddress?.pincode ?? "";
    addressController.text = widget.savedAddress?.address ?? "";
    stateController.text = widget.savedAddress?.state ?? "";
    cityController.text = widget.savedAddress?.city ?? "";

    pincodeController.addListener(() {
      if (pincodeController.text.length == 6) {
        _fetchCityState(pincodeController.text);
      }
    });

    super.initState();
  }

  Future<void> _fetchCityState(String pincode) async {
    isPincodeLoading.value = true;
    final data = await PincodeService.fetchCityState(pincode);
    isPincodeLoading.value = false;

    if (data != null) {
      final city = data['city'] ?? "";
      final state = data['state'] ?? "";

      if (city.toLowerCase().contains("delhi") ||
          city.toLowerCase().contains("chandigarh") ||
          state.toLowerCase().contains("delhi") ||
          state.toLowerCase().contains("chandigarh")) {
        // Since state names from API might differ slightly (e.g. "Delhi" vs "Delhi"),
        // we might want to map them to our list or just set them.
        // For now, setting them directly as text.

        // We need to match with our list keys if possible for dropdown consistency,
        // but since we are auto-filling text fields, setting text is fine.
        // However, state field is read-only and expects selection from bottom sheet usually.
        // Let's see if we can set the text directly.

        // Mapping simple "Delhi" to "Delhi" and "Chandigarh" to "Chandigarh"
        String mappedState = "";
        if (state.toLowerCase().contains("delhi")) {
          mappedState = "Delhi";
        } else if (state.toLowerCase().contains("chandigarh")) {
          mappedState = "Chandigarh";
        }

        if (mappedState.isNotEmpty) {
          stateController.text = mappedState;
          cityController.text = city; // API returns District as City usually

          // Clear errors
          stateError.value = '';
          cityError.value = '';
          pincodeError.value = '';
        } else {
          // Should not happen if outer if check passes
          stateController.text = state;
          cityController.text = city;
        }
      } else {
        toast("We are serviceable for Chandigarh and Delhi only",
            type: ToastType.warning);
        // Clear fields or keep them? User requirements say "give error on sacve adress" if outside.
        // But also said "make sure if out side delhi channdigarh pincode enter give error on sacve adress"
        // And "based on pincode enter fill state and city wich match in our list"

        // If it doesn't match our list (Delhi/Chandigarh), we probably shouldn't fill it?
        // Or fill it and let validation catch it?
        // "also make sure if out side delhi channdigarh pincode enter give error on sacve adress" implies validation on save.
        // But "fill state and city wich match in our list" implies only fill if it matches.

        // Let's fill it to let the user see what happened, but show the toast immediately as per "give error".
        // Actually, if we fill it with non-Delhi/Chandigarh, the save validation will catch it.
        // But the previous requirement was "Restrict address addition".
        // The *state* field is read-only. If we set it to "Maharashtra", the user can't change it easily if they want to correct it without changing pincode?
        // Actually they can click the field to open sheet.

        // Let's NOT fill if it's not serviceable, to enforce "Restriction".
        stateController.clear();
        cityController.clear();
      }
    } else {
      toast("Invalid Pincode", type: ToastType.error);
      stateController.clear();
      cityController.clear();
    }
  }

  void validateAndSave() {
    final error1 = validateCommonField(nameController.text.trim(), "name");

    final error2 = validateMobileNumber(mobileNoController.text.trim(), 10, 10);
    final error3 = validatePincode(pincodeController.text.trim(), 6, 6);
    final error4 = validateCommonField(nameController.text.trim(), "address");
    final error5 = validateCommonField(stateController.text.trim(), "state");
    final error6 = validateCommonField(cityController.text.trim(), "city");

    nameError.value = error1 ?? '';
    mobileError.value = error2 ?? '';
    pincodeError.value = error3 ?? '';
    addressError.value = error4 ?? '';
    stateError.value = error5 ?? '';
    cityError.value = error6 ?? '';

    if (error1 == null &&
        error2 == null &&
        error3 == null &&
        error4 == null &&
        error5 == null &&
        error6 == null) {
      final state = stateController.text.toLowerCase();
      final city = cityController.text.toLowerCase();
      if ((state.contains("delhi") || state.contains("chandigarh")) ||
          (city.contains("delhi") || city.contains("chandigarh"))) {
        saveAddressApi();
      } else {
        toast("We are serviceable for Chandigarh and Delhi only",
            type: ToastType.warning);
      }
    }
  }

  Future<void> saveAddressApi() async {
    try {
      isLoading.value = true;

      var result = await NetworkClient.instance.callApi(
          widget.isEdit
              ? "${ApiConstants.addresses}/${widget.savedAddress?.id}"
              : "${ApiConstants.addresses}",
          widget.isEdit ? MethodType.patch : MethodType.post,
          baseUrlType: BaseUrl.base,
          params: {
            "name": nameController.text.trim(),
            "mobile": "+91 ${mobileNoController.text.trim()}",
            "pincode": pincodeController.text.trim(),
            "address": addressController.text.trim(),
            "city": cityController.text.trim(),
            "state": stateController.text.trim()
          });

      if (result.isSuccess) {
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        widget.onSuccess?.call(); // ✅ trigger success callback

        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
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
    return Obx(() => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
              .copyWith(bottom: 0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Text(
                      widget.isEdit
                          ? "Edit Address".toUpperCase()
                          : "Add new Address".toUpperCase(),
                      style: style700S12.copyWith(
                          letterSpacing: 0.96, color: Color(0xFFCCCCCC)),
                    ),
                    hSizedBox12,
                    AppTextField(
                      label: "Name".toUpperCase(),
                      controller: nameController,
                      isRequired: true,
                      hint: "Enter Name",
                      isGradientBorder: true,
                      fillColor: AppColors.whiteColor.withAlpha(12),
                      hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                      errorText:
                          nameError.value.isEmpty ? null : nameError.value,
                      onChanged: (value) {
                        if (nameError.value.isNotEmpty) {
                          nameError.value = '';
                        }
                      },
                    ),
                    hSizedBox24,
                    AppTextField(
                      label: "Mobile Number".toUpperCase(),
                      controller: mobileNoController,
                      isRequired: true,
                      hint: "Enter Mobile Number",
                      isGradientBorder: true,
                      maxLength: 10,
                      fillColor: AppColors.whiteColor.withAlpha(12),
                      hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      prefixIcon: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🇮🇳+91', style: style400S16),
                          hSizedBox2,
                        ],
                      ),
                      errorText:
                          mobileError.value.isEmpty ? null : mobileError.value,
                      onChanged: (value) {
                        if (mobileError.value.isNotEmpty) {
                          mobileError.value = '';
                        }
                      },
                    ),
                    hSizedBox24,
                    AppTextField(
                      label: "Pincode".toUpperCase(),
                      controller: pincodeController,
                      isRequired: true,
                      hint: "Enter Pincode",
                      isGradientBorder: true,
                      maxLength: 6,
                      fillColor: AppColors.whiteColor.withAlpha(12),
                      hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      errorText: pincodeError.value.isEmpty
                          ? null
                          : pincodeError.value,
                      suffixIcon: Obx(() => isPincodeLoading.value
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: Center(
                                child: SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.whiteColor,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox.shrink()),
                      onChanged: (value) {
                        if (pincodeError.value.isNotEmpty) {
                          pincodeError.value = '';
                        }
                      },
                    ),
                    hSizedBox24,
                    AppTextField(
                      label: "Address".toUpperCase(),
                      controller: addressController,
                      isRequired: true,
                      hint: "Select Address",
                      isGradientBorder: true,
                      fillColor: AppColors.whiteColor.withAlpha(12),
                      hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                      errorText: addressError.value.isEmpty
                          ? null
                          : addressError.value,
                      onChanged: (value) {
                        if (addressError.value.isNotEmpty) {
                          addressError.value = '';
                        }
                      },
                    ),
                    hSizedBox24,
                    AppTextField(
                      label: "State".toUpperCase(),
                      controller: stateController,
                      isRequired: true,
                      hint: "Select State",
                      isGradientBorder: true,
                      fillColor: AppColors.whiteColor.withAlpha(12),
                      hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                      readOnly: true,
                      suffixIcon: Transform.rotate(
                          angle: 3.14159,
                          child: SvgPicture.asset(
                            AssetConstants.backward,
                            height: 24,
                          )),
                      errorText:
                          stateError.value.isEmpty ? null : stateError.value,
                      onTap: () async {
                        final selectedState =
                            await BlurBottomSheet().show<String>(
                          height: MediaQuery.sizeOf(context).height * 0.9,
                          context: context,
                          borderColor: AppColors.whiteColor.withAlpha(40),
                          backgroundColor:
                              AppColors.scaffoldColor.withAlpha(200),
                          barrierColor: AppColors.blackColor.withAlpha(50),
                          blurStrength: 10,
                          isCloseButton: true,
                          child: StateListBottomSheet(),
                        );

                        if (selectedState != null) {
                          stateController.text = selectedState;
                          cityController.text = "";
                          if (stateError.value.isNotEmpty) {
                            stateError.value = '';
                          }
                        }
                      },
                    ),
                    hSizedBox24,
                    AppTextField(
                      label: "City".toUpperCase(),
                      controller:
                          cityController, // Add this Rx<TextEditingController>
                      isRequired: true,
                      hint: "Select City",
                      isGradientBorder: true,
                      fillColor: AppColors.whiteColor.withAlpha(12),
                      hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                      readOnly: true,
                      suffixIcon: Transform.rotate(
                          angle: 3.14159,
                          child: SvgPicture.asset(
                            AssetConstants.backward,
                            height: 24,
                          )),
                      errorText:
                          cityError.value.isEmpty ? null : cityError.value,

                      onTap: () async {
                        if (stateController.value.text.isEmpty) {
                          toast("Please select a state first");
                          return;
                        }

                        final selectedCity =
                            await BlurBottomSheet().show<String>(
                          height: MediaQuery.sizeOf(context).height * 0.9,
                          context: context,
                          borderColor: AppColors.whiteColor.withAlpha(40),
                          backgroundColor:
                              AppColors.scaffoldColor.withAlpha(200),
                          barrierColor: AppColors.blackColor.withAlpha(50),
                          blurStrength: 10,
                          isCloseButton: true,
                          child: CityListBottomSheet(
                              stateName: stateController.value.text),
                        );

                        if (selectedCity != null) {
                          cityController.text = selectedCity;
                          if (cityError.value.isNotEmpty) {
                            cityError.value = '';
                          }
                        }
                      },
                    ),
                    hSizedBox10,
                  ],
                ),
              ),
              KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
                return isKeyboardVisible
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SafeArea(
                          top: false,
                          child: Obx(() => AppButton(
                                onTap: () {
                                  validateAndSave();
                                },
                                isLoading: isLoading.value,
                                text: "Save Address",
                                textColor: AppColors.blackColor,
                                loaderColor: AppColors.blackColor,
                                gradientBorderColors:
                                    AppColors.glassBorderGradient,
                              )),
                        ),
                      );
              }),
            ],
          ),
        ));
  }
}
