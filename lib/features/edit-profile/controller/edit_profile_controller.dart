import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/validators.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/home/controller/home_controller.dart';
import 'package:vousvous/features/user-profile/controller/user_profile_controller.dart';

/// Username validation status for color coding
enum UsernameStatus { empty, checking, success, error }

class EditProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoading2 = false.obs;

  final Rx<File> newProfileImage = File("").obs;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController bioController = TextEditingController();

  final RxString nameError = ''.obs;
  final RxString bioError = ''.obs;

  // Username validation states - single message with status
  final RxBool isUsernameAvailable = false.obs;
  final RxString usernameStatusMessage = ''.obs; // One message for all states
  final Rx<UsernameStatus> usernameStatus = UsernameStatus.empty.obs;
  String? _originalUsername;
  Timer? _debounceTimer;

  @override
  void onInit() {
    nameController.text =
        LocalStorageService.instance.userInfo.value.data?.name ?? "";
    _originalUsername =
        LocalStorageService.instance.userInfo.value.data?.username ?? "";
    usernameController.text = _originalUsername ?? "";
    mobileNoController.text =
        "${LocalStorageService.instance.userInfo.value.data?.phone ?? ""} ";
    bioController.text =
        LocalStorageService.instance.userInfo.value.data?.bio ?? "";
    super.onInit();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Check username availability with debounce
  void onUsernameChanged(String value) {
    // Cancel any pending API call
    _debounceTimer?.cancel();

    final username = value.trim().toLowerCase();

    // Reset state
    isUsernameAvailable.value = false;

    // Validate format first
    if (username.isEmpty) {
      usernameStatus.value = UsernameStatus.error;
      usernameStatusMessage.value = 'Username is required';
      return;
    }

    if (username.length < 3) {
      usernameStatus.value = UsernameStatus.error;
      usernameStatusMessage.value = 'Username must be at least 3 characters';
      return;
    }

    if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
      usernameStatus.value = UsernameStatus.error;
      usernameStatusMessage.value =
          'Only lowercase letters, numbers, and underscore allowed';
      return;
    }

    // If same as original, no need to check
    if (username == _originalUsername?.toLowerCase()) {
      isUsernameAvailable.value = true;
      usernameStatus.value = UsernameStatus.success;
      usernameStatusMessage.value = 'Current username';
      return;
    }

    // Show checking state with debounce
    usernameStatus.value = UsernameStatus.checking;
    usernameStatusMessage.value = 'Checking availability...';

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      checkUsernameAvailability(username);
    });
  }

  /// Call API to check username availability
  Future<void> checkUsernameAvailability(String username) async {
    try {
      var result = await NetworkClient.instance.callApi(
        '${ApiConstants.checkUsername}?username=$username',
        MethodType.post,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        // API response: {success, message, data: {isAvailable}}
        final responseData = result.data?.data;
        final isAvailable = responseData?['data']?['isAvailable'] ?? false;
        final message = responseData?['message'] ?? '';

        if (isAvailable) {
          isUsernameAvailable.value = true;
          usernameStatus.value = UsernameStatus.success;
          usernameStatusMessage.value =
              isNotNullOrEmpty(message) ? message : 'Username is available';
        } else {
          isUsernameAvailable.value = false;
          usernameStatus.value = UsernameStatus.error;
          usernameStatusMessage.value =
              isNotNullOrEmpty(message) ? message : 'Username is already taken';
        }
      } else {
        usernameStatus.value = UsernameStatus.error;
        usernameStatusMessage.value =
            result.error?.toString() ?? 'Failed to check availability';
      }
    } catch (e) {
      usernameStatus.value = UsernameStatus.error;
      usernameStatusMessage.value = 'Failed to check availability';
    }
  }

  void validateAndUpdateProfile() {
    final error1 = validateCommonField(nameController.text.trim(), "name");
    final error2 = validateCommonField(bioController.text.trim(), "bio");

    // Validate username
    final username = usernameController.text.trim().toLowerCase();
    String? error3;
    if (username.isEmpty) {
      error3 = 'Username is required';
    } else if (username.length < 3) {
      error3 = 'Username must be at least 3 characters';
    } else if (!RegExp(r'^[a-z0-9_]+$').hasMatch(username)) {
      error3 = 'Invalid username format';
    } else if (!isUsernameAvailable.value &&
        username != _originalUsername?.toLowerCase()) {
      error3 = 'Username is not available';
    }

    nameError.value = error1 ?? '';
    if (error3 != null) {
      usernameStatus.value = UsernameStatus.error;
      usernameStatusMessage.value = error3;
    }
    bioError.value = error2 ?? '';

    if (error1 == null && error2 == null && error3 == null) {
      updateProfileApi();
    }
  }

  Future<void> updateProfileApi() async {
    try {
      isLoading.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.updateProfileDetail}", MethodType.patch,
          baseUrlType: BaseUrl.base,
          params: {
            "name": nameController.text.trim(),
            "username": usernameController.text.trim().toLowerCase(),
            "bio": bioController.text.trim(),
          });
      if (result.isSuccess) {
        if (isNullOrEmpty(newProfileImage.value.path)) {
          toast("Profile Update Successfully!", type: ToastType.success);
          if (Get.isRegistered<HomeController>()) {
            Get.find<HomeController>().getUserDetail();
          }
          if (Get.isRegistered<UserProfileController>()) {
            Get.find<UserProfileController>().getUserDetail();
          }
          Get.back();
        } else {
          updateProfileImageApi();
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

  Future<void> updateProfileImageApi() async {
    try {
      isLoading2.value = true;
      var result = await NetworkClient.instance
          .callApi("${ApiConstants.updateProfileImage}", MethodType.patch,
              baseUrlType: BaseUrl.base,
              headers: {"Content-Type": "multipart/form-data"},
              params: dio.FormData.fromMap({
                'image': dio.MultipartFile.fromFileSync(
                  newProfileImage.value.path,
                  filename: newProfileImage.value.path.split('/').last,
                  contentType: dio.DioMediaType("image", "png"),
                )
              }));

      if (result.isSuccess) {
        toast("Profile Update Successfully!", type: ToastType.success);
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().getUserDetail();
        }
        if (Get.isRegistered<UserProfileController>()) {
          Get.find<UserProfileController>().getUserDetail();
        }
        Get.back();
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading2.value = false;
    }
  }
}
