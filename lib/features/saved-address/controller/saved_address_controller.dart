import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/saved-address/models/saved_address_model.dart';
import 'package:get/get.dart';

class SavedAddressController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoading2 = false.obs;

  final Rx<SavedAddressModel> savedAddressModel = SavedAddressModel().obs;

  @override
  void onInit() {
    getSavedAddress();
    super.onInit();
  }

  Future<void> getSavedAddress() async {
    try {
      isLoading.value = true;
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.addresses}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        savedAddressModel.value = SavedAddressModel.fromJson(result.data?.data);
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSavedAddress(String? id) async {
    try {
      isLoading2.value = true;
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.addresses}/$id",
        MethodType.delete,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }
        getSavedAddress();
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
