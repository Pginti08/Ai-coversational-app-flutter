import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    manageScrollController();
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

    super.onInit();
  }

  void manageScrollController() async {
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (userProfileController.nextPageStop.isTrue &&
            userProfileController.paginationLoading.isFalse) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent + 100,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
          userProfileController.paginationLoading.value = true;
          if (userProfileController.isYou) {
            userProfileController.getProductListApi(isInitial: false);
          } else {
            userProfileController.getOtherUserProductListApi(isInitial: false);
          }
        }
      }
    });
  }
}
