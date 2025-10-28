import 'package:get/get.dart';

class RemixedProductController extends GetxController {
  String imageUrl = "";
  @override
  void onInit() {
    if (Get.arguments != null && Get.arguments["imageUrl"] != null) {
      imageUrl = Get.arguments["imageUrl"];
    }
    super.onInit();
  }
}
