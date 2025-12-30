import 'package:get/get.dart';
import 'package:vousvous/routes/app_pages.dart';
// In splash_controller.dart

class SplashController extends GetxController {
  @override
  void onInit() {
    // Always wait for the 2800ms
    Future.delayed(Duration(milliseconds: 2800), () {
      Get.offAllNamed(Routes.welcome);
    });
    super.onInit();
  }
}
