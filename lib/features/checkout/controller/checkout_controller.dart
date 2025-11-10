import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/saved-address/models/saved_address_model.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:get/get.dart';

class CheckoutController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoading2 = false.obs;
  Rxn<SavedAddress> selectedAddress = Rxn<SavedAddress>();
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

  Future<void> placeOrderApi() async {
    try {
      isLoading2.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.orders}", MethodType.post,
          baseUrlType: BaseUrl.base,
          params: {
            "addressId": selectedAddress.value?.id,
            "paymentMode": "CBD"
          });
      if (result.isSuccess) {
        toast("Your Order Placed successfully!", type: ToastType.success);
        Get.until((route) => Get.currentRoute == Routes.home);
        Get.toNamed(Routes.orders);
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
