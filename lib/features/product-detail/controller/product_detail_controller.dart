import 'package:get/get.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';

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
