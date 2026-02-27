import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/flavors.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/common_dialog.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/home/models/user_detail_model.dart';
import 'package:vousvous/features/user-profile/controller/user_profile_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class HomeController extends GetxController with WidgetsBindingObserver {
  // Loaders
  final RxBool isLoading = false.obs;
  final RxBool isPaginating = false.obs;

  final RxBool hasSeenGuide = true.obs;

  // Drawer
  final RxBool isDrawerOpen = false.obs;

  // User info
  RxString userName =
      (LocalStorageService.instance.userInfo.value.data?.name ?? "").obs;
  RxString userImage =
      (LocalStorageService.instance.userInfo.value.data?.image ?? "").obs;

  // Products
  final RxList<Product> suggestedProductsList = <Product>[].obs;
  RxInt currentCardIndex = 0.obs;
  RxInt remainingProductsInQueue = 0.obs;

  int currentPage = 1;
  bool hasMoreProducts = true;

  // Swipe tracking
  final RxInt totalSwipes = 0.obs;
  final int requiredSwipes = 15;

  // ─────────────────────────────────────────────────────────────

  @override
  void onInit() {
    WidgetsBinding.instance.addObserver(this);
    hasSeenGuide.value =
        LocalStorageService.instance.userInfo.value.data?.hasSeenGuide ?? true;
    getUserDetail();
    getSuggestedProducts();

    super.onInit();
  }

  @override
  void onReady() {
    if (!kDebugMode && Flavor.getFlavor == FlavorType.production) {
      getNewAppVersion();
    }
    super.onReady();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// 🔥 THIS IS THE KEY FIX
  /// Called every time app comes to foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        !kDebugMode &&
        Flavor.getFlavor == FlavorType.production) {
      getNewAppVersion();
    }
  }

  void toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value;
  }
  // ─────────────────────────────────────────────────────────────
  // USER
  // ─────────────────────────────────────────────────────────────

  Future<void> getUserDetail() async {
    try {
      var result = await NetworkClient.instance.callApi(
        ApiConstants.getUserDetail,
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
        totalSwipes.value =
            LocalStorageService.instance.userInfo.value.data?.swipeCount ?? 0;
        hasSeenGuide.value =
            LocalStorageService.instance.userInfo.value.data?.hasSeenGuide ??
                true;
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
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

  // ─────────────────────────────────────────────────────────────
  // PRODUCTS
  // ─────────────────────────────────────────────────────────────

  Future<void> getSuggestedProducts({bool isLoadMore = false}) async {
    if (isLoading.value || isPaginating.value) return;
    if (isLoadMore && !hasMoreProducts) return;

    try {
      isLoadMore ? isPaginating.value = true : isLoading.value = true;

      if (isLoadMore) currentPage++;

      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.getSuggestedProducts}?page=$currentPage",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (!result.isSuccess) {
        toast(result.error.toString());
        return;
      }

      final model = ProductListModel.fromJson(result.data?.data);
      final newProducts = model.data ?? [];

      if (newProducts.length < 10) hasMoreProducts = false;

      if (!isLoadMore) {
        suggestedProductsList.clear();
        remainingProductsInQueue.value = 0;
      }

      suggestedProductsList.addAll(newProducts);
      remainingProductsInQueue.value += newProducts.length;
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
      isPaginating.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────
  // LIKE / SKIP
  // ─────────────────────────────────────────────────────────────

  Future<void> likedProduct(String productId) async {
    try {
      UserProfileController.updateLikeSession(productId, true);
      await NetworkClient.instance.callApi(
        "/product/$productId/like",
        MethodType.post,
        baseUrlType: BaseUrl.base,
      );
    } catch (_) {}
  }

  Future<void> skipProduct(String productId) async {
    try {
      await NetworkClient.instance.callApi(
        "/product/$productId/skip",
        MethodType.post,
        baseUrlType: BaseUrl.base,
      );
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────
  // SWIPES
  // ─────────────────────────────────────────────────────────────

  void onCardSwiped() {
    totalSwipes.value++;

    final current = LocalStorageService.instance.userInfo.value;
    LocalStorageService.instance.setUserInfo(
      current.copyWith(
        data: current.data?.copyWith(swipeCount: totalSwipes.value),
      ),
    );

    if (totalSwipes.value == requiredSwipes) {
      _showCustomizationAvailablePopup();
    }
  }

  void _showCustomizationAvailablePopup() {
    commonDialog(
      title: "Customize Your Style",
      description: "You can personalize your outfits to match your taste",
      successButtonTitle: "Start Creating",
      cancelButtonTitle: "Later",
      onSuccess: () {
        Get.back();
        Get.toNamed(Routes.chat);
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // APP UPDATE (using new_version_plus)
  // ─────────────────────────────────────────────────────────────

  /// Flag to prevent showing update dialog multiple times in same session
  bool _hasShownUpdateDialog = false;

  Future<void> getNewAppVersion() async {
    // Prevent showing dialog multiple times
    if (_hasShownUpdateDialog) return;

    try {
      final newVersion = NewVersionPlus(
        androidId: 'com.vrozart.vousvous',
        iOSId: '6757326777',
      );

      final status = await newVersion.getVersionStatus();

      if (status == null) {
        debugPrint('📱 Could not get version status');
        return;
      }

      debugPrint('📱 Current version: ${status.localVersion}');
      debugPrint('📱 Store version: ${status.storeVersion}');
      debugPrint('📱 Can update: ${status.canUpdate}');
      debugPrint('📱 App Store URL: ${status.appStoreLink}');

      if (status.canUpdate) {
        _hasShownUpdateDialog = true;
        _showForceUpdateDialog(status.appStoreLink);
      }
    } catch (e) {
      debugPrint('❌ Version check error: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────
  // DIALOGS
  // ─────────────────────────────────────────────────────────────

  void _showForceUpdateDialog(String storeUrl) {
    commonDialog(
      title: "⚠️ Update Required",
      description: "A new version is available. Please update to continue.",
      showCancel: false,
      isDismissible: false,
      successButtonTitle: "Update Now",
      onSuccess: () async {
        await launchUrl(Uri.parse(storeUrl),
            mode: LaunchMode.externalApplication);
      },
    );
  }
}
