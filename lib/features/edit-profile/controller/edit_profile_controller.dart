import 'dart:io';

import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/local_storage_service.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/validators.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/home/controller/home_controller.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoading2 = false.obs;

  final Rx<File> newProfileImage = File("").obs;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileNoController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  RxBool isPrivatePost = true.obs;

  final RxString nameError = ''.obs;
  final RxString bioError = ''.obs;

  @override
  void onInit() {
    nameController.text =
        LocalStorageService.instance.userInfo.value.data?.name ?? "";
    mobileNoController.text =
        "${LocalStorageService.instance.userInfo.value.data?.countryCode ?? ""} ${LocalStorageService.instance.userInfo.value.data?.phone ?? ""} ";
    bioController.text =
        LocalStorageService.instance.userInfo.value.data?.bio ?? "";
    isPrivatePost.value =
        LocalStorageService.instance.userInfo.value.data?.isPrivatePost ??
            false;
    super.onInit();
  }

  void validateAndUpdateProfile() {
    final error1 = validateCommonField(nameController.text.trim(), "name");

    final error2 = validateCommonField(bioController.text.trim(), "bio");
    nameError.value = error1 ?? '';
    bioError.value = error2 ?? '';

    if (error1 == null && error2 == null) {
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
            "bio": bioController.text.trim(),
            "isPrivatePost": isPrivatePost.value
          });
      if (result.isSuccess) {
        if (isNullOrEmpty(newProfileImage.value.path)) {
          toast("Profile Update Successfully!", type: ToastType.success);
          Get.find<HomeController>().getUserDetail();
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
        Get.find<HomeController>().getUserDetail();
      } else {
        toast(result.error.toString());
        Get.find<HomeController>().getUserDetail();
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading2.value = false;
    }
  }
}
