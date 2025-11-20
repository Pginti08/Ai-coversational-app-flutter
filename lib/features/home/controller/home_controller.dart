import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/home/models/user_detail_model.dart';
import 'package:vousvous/features/home/screens/home_screen.dart';

class HomeController extends GetxController {
// isLoading for the initial, full-screen load.
  final RxBool isLoading = false.obs;
  // isPaginating for background "load more" actions.
  final RxBool isPaginating = false.obs;

  var currentGuideStep = GuideStep.none.obs;
  // 3. Keep track of the user's guide status
  var hasSeenGuide = true.obs;

  RxString userName =
      (LocalStorageService.instance.userInfo.value.data?.name ?? "").obs;
  RxString userImage =
      (LocalStorageService.instance.userInfo.value.data?.image ?? "").obs;

  final RxBool isDrawerOpen = false.obs;

  RxInt currentCardIndex = 0.obs;

  final RxList<Product> suggestedProductsList = <Product>[].obs;

  RxInt remainingProductsInQueue = 0.obs;

  @override
  void onInit() {
    getUserDetail();
    getSuggestedProducts();
    super.onInit();
  }

  void toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value;
  }

  Future<void> getUserDetail() async {
    try {
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.getUserDetail}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        LocalStorageService.instance
            .setUserInfo(UserDetailModel.fromJson(result.data?.data));
        userName.value =
            LocalStorageService.instance.userInfo.value.data?.name ?? "";
        userImage.value =
            LocalStorageService.instance.userInfo.value.data?.image ?? "";
        checkUserGuideStatus();
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {}
  }

  void checkUserGuideStatus() {
    // Get the status from your local storage or user model
    // This is just an example, adapt it to your actual service
    final userHasSeenGuide =
        LocalStorageService.instance.userInfo.value.data?.hasSeenGuide ?? true;
    hasSeenGuide.value = userHasSeenGuide;

    if (!userHasSeenGuide) {
      // Start the guide at the first step
      currentGuideStep.value = GuideStep.dragDown;
    } else {
      currentGuideStep.value = GuideStep.done;
    }
  }

  Future<void> markGuideSeen() async {
    try {
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.guideSeen}",
        MethodType.patch,
        baseUrlType: BaseUrl.base,
      );
      if (result.isSuccess) {
        LocalStorageService.instance.setUserInfo(
            LocalStorageService.instance.userInfo.value.copyWith(
                data: LocalStorageService.instance.userInfo.value.data
                    ?.copyWith(hasSeenGuide: true)));
      }
    } catch (e) {}
  }

  Future<void> getSuggestedProducts({bool isLoadMore = false}) async {
    // Guard against simultaneous fetches.
    if (isLoading.value || isPaginating.value) return;

    try {
      // We now use the isLoadMore flag to determine which loader to show.
      if (isLoadMore) {
        isPaginating.value = true;
      } else {
        isLoading.value = true;
      }

      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.getSuggestedProducts}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        var suggestedProductModel =
            ProductListModel.fromJson(result.data?.data);

        final newProducts = suggestedProductModel.data ?? [];

        // If it's an initial load, clear any old data first.
        if (!isLoadMore) {
          suggestedProductsList.clear();
          remainingProductsInQueue.value = 0;
        }

        suggestedProductsList.addAll(newProducts);
        remainingProductsInQueue.value += newProducts.length;
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      // Always reset both loaders.
      isLoading.value = false;
      isPaginating.value = false;
    }
  }

  Future<void> likedProduct(String productId) async {
    try {
      await NetworkClient.instance.callApi(
        "/product/$productId/like",
        MethodType.post,
        baseUrlType: BaseUrl.base,
      );
    } catch (e) {}
  }

  Future<void> skipProduct(String productId) async {
    try {
      await NetworkClient.instance.callApi(
        "/product/$productId/skip",
        MethodType.post,
        baseUrlType: BaseUrl.base,
      );
    } catch (e) {}
  }
}
