import 'package:ai_fashion/routes/app_pages.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  RxBool loader = false.obs;
  @override
  void onInit() {
    Future.delayed(Duration(milliseconds: 2800), () {
      Get.offNamed(Routes.welcome);
    });
    super.onInit();
  }
}
