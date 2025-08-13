import 'package:ai_fashion/routes/app_pages.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  RxBool loader = false.obs;
  @override
  void onInit() {
    Future.delayed(Duration(milliseconds: 1500), () {
      Get.offNamed(Routes.home);
    });
    super.onInit();
  }
}
