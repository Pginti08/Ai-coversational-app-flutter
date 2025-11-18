import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/body-profile/models/saved_body_profile_model.dart';
import 'package:get/get.dart';

class BodyProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoading2 = false.obs;

  final Rx<SavedBodyProfileModel> savedBodyProfileModel =
      SavedBodyProfileModel().obs;

  @override
  void onInit() {
    getSavedBodyProfile();
    super.onInit();
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
