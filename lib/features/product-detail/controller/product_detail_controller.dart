import 'package:ai_fashion/features/home/models/product_list_model.dart';
import 'package:get/get.dart';

class ProductDetailController extends GetxController {
  Product? productDetail;
  @override
  void onInit() {
    if (Get.arguments != null && Get.arguments["productDetail"] != null) {
      productDetail = Get.arguments["productDetail"];
    }
    super.onInit();
  }
}
