import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/flavors.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/common_dialog.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/home/models/user_detail_model.dart';
import 'package:vousvous/features/home/screens/home_screen.dart';
import 'package:vousvous/features/user-profile/controller/user_profile_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

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

  // Track current page for pagination
  int currentPage = 1;
  bool hasMoreProducts = true;

  // Unlock customization tracking
  final RxInt totalSwipes = 0.obs;
  final int requiredSwipes = 15;

  @override
  void onInit() {
    getUserDetail();
    getSuggestedProducts();

    super.onInit();
  }

  @override
  void onReady() {
    getNewAppVersion();
    super.onReady();
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
        totalSwipes.value =
            LocalStorageService.instance.userInfo.value.data?.swipeCount ?? 0;
        checkUserGuideStatus();
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {}
  }

  void checkUserGuideStatus() {
    // Guide disabled
    currentGuideStep.value = GuideStep.none;
    /*
    final userHasSeenGuide =
        LocalStorageService.instance.userInfo.value.data?.hasSeenGuide ?? true;
    hasSeenGuide.value = userHasSeenGuide;

    if (!userHasSeenGuide) {
      // Start the guide at the first step
      currentGuideStep.value = GuideStep.dragDown;
    } else {
      currentGuideStep.value = GuideStep.done;
    }
    */
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
    print("🔥 getSuggestedProducts called - isLoadMore: $isLoadMore");

    // Guard against simultaneous fetches.
    if (isLoading.value || isPaginating.value) {
      print("⚠️ Already loading or paginating, returning...");
      return;
    }

    // If no more products available and it's a load more request, don't fetch
    if (isLoadMore && !hasMoreProducts) {
      print("⚠️ No more products available, returning...");
      return;
    }

    try {
      // We now use the isLoadMore flag to determine which loader to show.
      if (isLoadMore) {
        isPaginating.value = true;
        print("📄 Paginating...");
      } else {
        isLoading.value = true;
        print("⏳ Loading...");
      }

      // If shuffle, reset to page 1, otherwise increment page for load more
      if (isLoadMore) {
        currentPage++;
        print("➕ LOAD MORE - Incrementing to page $currentPage");
      }

      print("📡 Fetching page $currentPage from API...");
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.getSuggestedProducts}?page=$currentPage",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        var suggestedProductModel =
            ProductListModel.fromJson(result.data?.data);

        final newProducts = suggestedProductModel.data ?? [];
        print(
            "✅ API Success - Received ${newProducts.length} products from page $currentPage");

        // Check if we got fewer products than expected (indicates last page)
        if (newProducts.isEmpty || newProducts.length < 10) {
          hasMoreProducts = false;
          print(
              "🚫 hasMoreProducts set to FALSE (received ${newProducts.length} products)");
        } else {
          print("✅ hasMoreProducts is TRUE");
        }

        // If it's a shuffle or initial load, clear any old data first.
        if (!isLoadMore) {
          print(
              "🗑️ Clearing old products list (had ${suggestedProductsList.length} products)");
          suggestedProductsList.clear();
          remainingProductsInQueue.value = 0;
          // currentCardIndex.value = 0;
        }

        suggestedProductsList.addAll(newProducts);
        remainingProductsInQueue.value += newProducts.length;

        print("📊 FINAL STATUS:");
        print("   - Total products in list: ${suggestedProductsList.length}");
        print("   - Remaining in queue: ${remainingProductsInQueue.value}");
        print("   - Current card index: ${currentCardIndex.value}");
        print("   - Current page: $currentPage");
        print("   - Has more products: $hasMoreProducts");
      } else {
        print("❌ API Error: ${result.error.toString()}");
        toast(result.error.toString());
      }
    } catch (e) {
      print("❌ Exception: ${e.toString()}");
      toast(e.toString());
    } finally {
      // Always reset both loaders.
      isLoading.value = false;
      isPaginating.value = false;
      print("✅ Loaders reset");
    }
  }

  Future<void> likedProduct(String productId) async {
    try {
      // 🛡️ Update session and disk
      UserProfileController.updateLikeSession(productId, true);

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

  void onCardSwiped() {
    totalSwipes.value++;

    // Update user info locally
    final currentUserInfo = LocalStorageService.instance.userInfo.value;
    final updatedData =
        currentUserInfo.data?.copyWith(swipeCount: totalSwipes.value);
    final updatedUserInfo = currentUserInfo.copyWith(data: updatedData);
    LocalStorageService.instance.setUserInfo(updatedUserInfo);

    // Show popup when reaching 15 swipes for the first time
    if (totalSwipes.value == requiredSwipes) {
      _showCustomizationAvailablePopup();
    }
  }

  void _showCustomizationAvailablePopup() {
    commonDialog(
      title: "Customize Your Style",
      description: 'You can personalize your outfits to match your taste',
      successButtonTitle: "Start Creating",
      cancelButtonTitle: "Later",
      onSuccess: () {
        Get.back();
        Get.toNamed(Routes.chat);
      },
    );
  }

  bool get canCustomize => totalSwipes.value >= requiredSwipes;
  int get remainingSwipesToCustomize =>
      (requiredSwipes - totalSwipes.value).clamp(0, requiredSwipes);

  getNewAppVersion() async {
    debugPrint("🔄 getNewAppVersion called");
    debugPrint("   kDebugMode: $kDebugMode");
    debugPrint("   Flavor: ${Flavor.getFlavor}");

    if ((!kDebugMode && Flavor.getFlavor == FlavorType.production)) {
      try {
        debugPrint("📡 Checking for app updates...");

        // Get current installed version
        final packageInfo = await PackageInfo.fromPlatform();
        final currentVersion = packageInfo.version;
        debugPrint("   Current installed version: $currentVersion");

        // Get store version
        String? storeVersion;

        if (Platform.isAndroid) {
          // Fetch version from Play Store
          storeVersion = await _getPlayStoreVersion();
        } else if (Platform.isIOS) {
          // Fetch version from App Store
          storeVersion = await _getAppStoreVersion();
        }

        debugPrint("   Store version: $storeVersion");

        if (storeVersion != null &&
            _isUpdateAvailable(currentVersion, storeVersion)) {
          debugPrint("✅ Update available! $currentVersion -> $storeVersion");
          commonDialog(
            title: "Update Required",
            description:
                "A new and improved version of the app is available.\nPlease update to continue using the app.",
            successButtonTitle: "Update Now",
            showCancel: false,
            isDismissible: false,
            onSuccess: () async {
              try {
                final url = Platform.isIOS
                    ? "https://apps.apple.com/app/vousvous/id6758098618"
                    : "https://play.google.com/store/apps/details?id=com.vrozart.vousvous";

                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              } catch (e) {
                debugPrint("❌ Failed to open store: $e");
              }
            },
          );
        } else {
          debugPrint("ℹ️ No update available");
        }
      } catch (e) {
        debugPrint("❌ Failed to check for updates: $e");
      }
    } else {
      debugPrint(
          "⚠️ Skipping update check - Debug: $kDebugMode, Flavor: ${Flavor.getFlavor}");
    }
  }

  /// Get version from Play Store
  Future<String?> _getPlayStoreVersion() async {
    try {
      const packageName = 'com.vrozart.vousvous';
      final url =
          'https://play.google.com/store/apps/details?id=$packageName&hl=en';

      final response = await NetworkClient.instance.dio.get(url);
      if (response.statusCode == 200) {
        final html = response.data.toString();
        // Look for version pattern in Play Store page
        // Pattern: [[[" followed by version number like "1.0.5"
        final versionRegex = RegExp(r'\[\[\[\"\d+\.\d+\.\d+');
        final match = versionRegex.firstMatch(html);
        if (match != null) {
          final version = match.group(0)?.replaceAll('[[[\"', '');
          return version;
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching Play Store version: $e");
    }
    return null;
  }

  /// Get version from App Store
  Future<String?> _getAppStoreVersion() async {
    try {
      const appId = '6758098618';
      final url = 'https://itunes.apple.com/lookup?id=$appId&country=in';

      final response = await NetworkClient.instance.dio.get(url);
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['resultCount'] > 0) {
          return data['results'][0]['version'];
        }
      }
    } catch (e) {
      debugPrint("❌ Error fetching App Store version: $e");
    }
    return null;
  }

  /// Compare versions to check if update is available
  bool _isUpdateAvailable(String currentVersion, String storeVersion) {
    try {
      final current = currentVersion.split('.').map(int.parse).toList();
      final store = storeVersion.split('.').map(int.parse).toList();

      // Pad with zeros if needed
      while (current.length < 3) current.add(0);
      while (store.length < 3) store.add(0);

      // Compare major.minor.patch
      for (int i = 0; i < 3; i++) {
        if (store[i] > current[i]) return true;
        if (store[i] < current[i]) return false;
      }
      return false;
    } catch (e) {
      debugPrint("❌ Error comparing versions: $e");
      return false;
    }
  }
}
