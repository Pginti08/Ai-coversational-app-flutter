import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/product-detail/models/check_quotation_exists_model.dart';
import 'package:vousvous/features/quotations/screens/select_body_profile_bottom_sheet.dart';
import 'package:vousvous/features/user-profile/controller/user_profile_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class PostsViewController extends GetxController {
  final RxList<Product> posts = <Product>[].obs;
  final RxInt initialIndex = 0.obs;
  final RxnString userName = RxnString();
  final RxnString userAvatar = RxnString();
  final RxBool isLoadingMore = false.obs;
  final RxBool isQuotationLoading = false.obs;
  final RxString activeQuotationUrl = "".obs;

  late UserProfileController userProfileController;

  // Replace ScrollController with ItemScrollController and ItemPositionsListener
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
      ItemPositionsListener.create();

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      if (Get.arguments["posts"] != null) {
        posts.value = List<Product>.from(Get.arguments["posts"]);
      }
      if (Get.arguments["initialIndex"] != null) {
        initialIndex.value = Get.arguments["initialIndex"];
      }
      if (Get.arguments["userName"] != null) {
        userName.value = Get.arguments["userName"];
      }
      if (Get.arguments["userAvatar"] != null) {
        userAvatar.value = Get.arguments["userAvatar"];
      }

      // 🛡️ Immediately sync passed posts with session cache
      _syncPostsWithSession();
    }

    // Find UserProfileController with tag if available
    String? tag;
    if (Get.arguments != null && Get.arguments['userId'] != null) {
      tag = Get.arguments['userId'];
    }

    try {
      userProfileController = Get.find<UserProfileController>(tag: tag);
    } catch (e) {
      userProfileController = Get.find<UserProfileController>();
    }

    // Setup listener after initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      manageScrollListener();
      scrollToInitialIndex();
    });
  }

  void scrollToInitialIndex() {
    if (initialIndex.value > 0 && posts.isNotEmpty) {
      if (itemScrollController.isAttached) {
        itemScrollController.jumpTo(
          index: initialIndex.value,
        );
      }
    }
  }

  void _syncPostsWithSession() {
    debugPrint(
        "🧨 EMERGENCY SYNC: Checking ${posts.length} posts against session cache");
    for (int i = 0; i < posts.length; i++) {
      final id = posts[i].id;
      if (id != null) {
        if (UserProfileController.sessionLikedIds.contains(id)) {
          debugPrint("❤️ Persistence Match (Init): $id");
          posts[i] = posts[i].copyWith(
            isLiked: true,
            likesCount: (posts[i].isLiked == true)
                ? posts[i].likesCount
                : (posts[i].likesCount ?? 0) + 1,
          );
        }
      }
    }
    posts.refresh();
  }

  void manageScrollListener() {
    itemPositionsListener.itemPositions.addListener(() {
      final positions = itemPositionsListener.itemPositions.value;

      if (positions.isNotEmpty) {
        // Get the last visible item index
        final lastVisibleIndex = positions
            .where((position) => position.itemTrailingEdge > 0)
            .map((position) => position.index)
            .reduce((a, b) => a > b ? a : b);

        // Check if we're near the end of the list
        if (lastVisibleIndex >= posts.length - 2) {
          if (userProfileController.nextPageStop.isTrue &&
              userProfileController.paginationLoading.isFalse) {
            userProfileController.paginationLoading.value = true;
            isLoadingMore.value = true;

            if (userProfileController.isYou) {
              userProfileController
                  .getProductListApi(isInitial: false)
                  .then((_) {
                isLoadingMore.value = false;
              });
            } else {
              userProfileController
                  .getOtherUserProductListApi(isInitial: false)
                  .then((_) {
                isLoadingMore.value = false;
              });
            }
          }
        }
      }
    });
  }

  Future<void> remixPost(String imageUrl) async {
    if (imageUrl.isEmpty) return;
    Get.toNamed(Routes.chat, arguments: {
      "isInitialRemix": true,
      "userSelectedRemixOutfits": [imageUrl]
    });
  }

  Future<void> checkQuotationStatus(
      BuildContext context, String imageUrl) async {
    try {
      isQuotationLoading.value = true;
      activeQuotationUrl.value = imageUrl;

      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.checkQuotationExists}?image=$imageUrl",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        var checkExistsQuotationModel =
            CheckQuotationExistsModel.fromJson(result.data?.data);
        if (checkExistsQuotationModel.data?.exists == true) {
          Get.toNamed(Routes.quotationChat, arguments: {
            "imageUrl": imageUrl,
            "quotationId": checkExistsQuotationModel.data?.quotationId,
          });
        } else {
          BlurBottomSheet().show<void>(
              height: MediaQuery.sizeOf(context).height * 0.8,
              context: context,
              borderColor: AppColors.whiteColor.withAlpha(40),
              backgroundColor: AppColors.scaffoldColor.withAlpha(200),
              barrierColor: AppColors.blackColor.withAlpha(50),
              blurStrength: 10,
              isCloseButton: true,
              child: SelectBodyProfileBottomSheet(
                image: imageUrl,
                aiAnalysis: checkExistsQuotationModel.data?.aiAnalysis,
              ));
        }
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isQuotationLoading.value = false;
      activeQuotationUrl.value = "";
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
    } catch (e) {
      debugPrint("‼️ Error in likedProduct: $e");
    }
  }

  Future<void> likePost(String productId) async {
    try {
      debugPrint("🚀 Calling Like API for: $productId");
      var result = await NetworkClient.instance.callApi(
        "/product/$productId/like",
        MethodType.post,
        baseUrlType: BaseUrl.base,
      );

      int index = posts.indexWhere((p) => p.id == productId);
      if (index == -1) return;

      if (result.isSuccess ||
          (result.error != null &&
              result.error.toString().contains("already liked"))) {
        debugPrint("✅ Like sync successful (Success or Already Liked)");

        final post = posts[index];
        bool currentlyLiked = post.isLiked ?? false;
        int currentLikes = post.likesCount ?? 0;

        // If it was already liked and we got that error, just ensure it's set to true
        bool nextLikedState = result.isSuccess ? !currentlyLiked : true;
        int nextLikes = nextLikedState
            ? (currentlyLiked ? currentLikes : currentLikes + 1)
            : (currentLikes > 0 ? currentLikes - 1 : 0);

        posts[index] = post.copyWith(
          isLiked: nextLikedState,
          likesCount: nextLikes,
        );

        posts.refresh();

        // 🛡️ User persistent update helper
        UserProfileController.updateLikeSession(productId, nextLikedState);

        // Also update the parent controller's list
        int profileIndex =
            userProfileController.posts.indexWhere((p) => p.id == productId);
        if (profileIndex != -1) {
          userProfileController.posts[profileIndex] = posts[index];
          userProfileController.posts.refresh();
        }

        if (nextLikedState && result.isSuccess) {}
      } else {
        debugPrint("❌ Like API Failed: ${result.error}");
        toast(result.error.toString());
      }
    } catch (e) {
      debugPrint("‼️ Like API Error Exception: $e");
    }
  }

  Future<void> deletePost(String productId) async {
    try {
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.product}/$productId",
        MethodType.delete,
        baseUrlType: BaseUrl.base,
      );
      if (result.isSuccess) {
        posts.removeWhere((p) => p.id == productId);
        userProfileController.posts.removeWhere((p) => p.id == productId);
        posts.refresh();
        userProfileController.posts.refresh();
        toast("Post deleted successfully", type: ToastType.success);
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    }
  }

  Future<bool> updatePost(String productId,
      {String? title,
      String? description,
      bool? isPrivate,
      String? type,
      String? color,
      String? material}) async {
    try {
      // Validate required fields
      if (title == null || title.trim().isEmpty) {
        toast("Title is required");
        return false;
      }

      if (description == null || description.trim().isEmpty) {
        toast("Description is required");
        return false;
      }

      Map<String, dynamic> params = {
        'title': title,
        'description': description,
      };

      if (isPrivate != null) params['isPrivate'] = isPrivate;
      if (type != null && type.trim().isNotEmpty) params['type'] = type;
      if (color != null && color.trim().isNotEmpty) params['color'] = color;
      if (material != null && material.trim().isNotEmpty)
        params['material'] = material;

      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.product}/$productId",
        MethodType.patch,
        baseUrlType: BaseUrl.base,
        params: params,
      );

      if (result.isSuccess) {
        // The API might return the updated object or just success
        // Let's use the local values to ensure immediate UI consistency
        int index = posts.indexWhere((p) => p.id == productId);
        if (index != -1) {
          posts[index] = posts[index].copyWith(
            title: title,
            description: description,
            isPrivate: isPrivate,
            updatedAt: DateTime.now(),
          );
          posts.refresh();
        }

        // Also update in user profile controller
        int profileIndex =
            userProfileController.posts.indexWhere((p) => p.id == productId);
        if (profileIndex != -1) {
          userProfileController.posts[profileIndex] =
              userProfileController.posts[profileIndex].copyWith(
            title: title,
            description: description,
            isPrivate: isPrivate,
            updatedAt: DateTime.now(),
          );
          userProfileController.posts.refresh();
        }
        toast("Post updated successfully", type: ToastType.success);
        return true;
      } else {
        toast(result.error.toString());
        return false;
      }
    } catch (e) {
      toast(e.toString());
      return false;
    }
  }
}
