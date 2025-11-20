import 'package:get/get.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/routes/app_pages.dart';

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
