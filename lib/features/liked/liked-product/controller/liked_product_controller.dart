import 'package:get/get.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';

class LikedProductController extends GetxController {
  String imageUrl = "";
  String productId = "";
  Rx<Product> productDetail = Product().obs;

  @override
  void onInit() {
    if (Get.arguments != null && Get.arguments["imageUrl"] != null) {
      imageUrl = Get.arguments["imageUrl"];
    }
    if (Get.arguments != null && Get.arguments["productId"] != null) {
      productId = Get.arguments["productId"];
    }
    if (Get.arguments != null && Get.arguments["productDetail"] != null) {
      productDetail.value = Get.arguments["productDetail"];
    }
    super.onInit();
  }
}
