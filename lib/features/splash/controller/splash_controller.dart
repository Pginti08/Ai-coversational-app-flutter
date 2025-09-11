import 'package:ai_fashion/core/constants/storage_constants.dart';
import 'package:ai_fashion/core/services/local_storage_service.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  RxBool loader = false.obs;
  @override
  void onInit() {
    Future.delayed(Duration(milliseconds: 2800), () {
      isNotNullOrEmpty(LocalStorageService.instance
              .getString(StorageConstants.accessToken))
          ? Get.offNamed(Routes.home)
          : Get.offNamed(Routes.welcome);
    });
    super.onInit();
  }
}
