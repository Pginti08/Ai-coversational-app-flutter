import 'package:get/get.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/routes/app_pages.dart';

class SharePreviewController extends GetxController {
  String imageUrl = "";
  String productId = "";

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      if (Get.arguments["productId"] != null) {
        productId = Get.arguments["productId"];
      }
      if (Get.arguments["imageUrl"] != null) {
        imageUrl = Get.arguments["imageUrl"];
      }
    }
  }

  Future<void> likedProduct() async {
    try {
      var result = await NetworkClient.instance.callApi(
        "/product/$productId/like",
        MethodType.post,
        baseUrlType: BaseUrl.base,
      );
      if (result.isSuccess) {
        Get.offAllNamed(Routes.liked);
      } else {
        toast(result.error.toString());
      }
    } catch (e) {}
  }
}
