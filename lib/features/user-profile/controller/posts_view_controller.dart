import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/user-profile/controller/user_profile_controller.dart';

class PostsViewController extends GetxController {
  final RxList<Product> posts = <Product>[].obs;
  final RxInt initialIndex = 0.obs;
  final RxnString userName = RxnString();
  final RxnString userAvatar = RxnString();
  final RxBool isLoadingMore = false.obs;

  UserProfileController userProfileController =
      Get.find<UserProfileController>();

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
}
