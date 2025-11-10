import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/orders-detail/models/order_detail_model.dart';
import 'package:get/get.dart';

class OrderDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  String orderId = "";

  final Rx<OrderDetailModel> orderDetailModel = OrderDetailModel().obs;

  @override
  void onInit() {
    if (Get.arguments != null && Get.arguments["orderId"] != null) {
      orderId = Get.arguments["orderId"];
    }
    getOrderDetail(orderId);
    super.onInit();
  }

  Future<void> getOrderDetail(String orderId) async {
    try {
      isLoading.value = true;
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.orders}/$orderId",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        orderDetailModel.value = OrderDetailModel.fromJson(result.data?.data);
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
