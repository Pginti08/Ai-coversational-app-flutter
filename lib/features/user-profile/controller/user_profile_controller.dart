import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/home/models/user_detail_model.dart';
import 'package:vousvous/features/user-profile/models/user_product_list_model.dart';

class UserProfileController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoading2 = false.obs;

  bool isYou = true;
  String userId = "";

  final Rx<UserDetailModel> userDetail = UserDetailModel().obs;

  RxInt page = 1.obs;
  RxBool paginationLoading = false.obs;
  RxBool nextPageStop = true.obs;

  final RxBool isFollowing = false.obs;
  final RxBool isFollowLoading = false.obs;

  final RxList<Product> productsList = <Product>[].obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null && Get.arguments["userId"] != null) {
      userId = Get.arguments["userId"];
      if (userId != LocalStorageService.instance.userInfo.value.data?.id) {
        isYou = false;
      } else {
        isYou = true;
      }
    }
    manageScrollController();
  }

  @override
  void onReady() {
    if (isYou) {
      getUserDetail();
      getProductListApi();
    } else {
      getOtherUserDetail();
      getOtherUserProductListApi();
    }
    super.onReady();
  }

  void manageScrollController() async {
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (nextPageStop.isTrue && paginationLoading.isFalse) {
          if (scrollController.hasClients) {
            scrollController.animateTo(
              scrollController.position.maxScrollExtent + 100,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
          paginationLoading.value = true;
          if (isYou) {
            getProductListApi(isInitial: false);
          } else {
            getOtherUserProductListApi(isInitial: false);
          }
        }
      }
    });
  }

  Future<void> getUserDetail() async {
    try {
      isLoading.value = true;

      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.getUserDetail}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        userDetail.value = UserDetailModel.fromJson(result.data?.data);
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getOtherUserDetail() async {
    try {
      isLoading.value = true;

      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.getUserProfile}/${userId}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        userDetail.value = UserDetailModel.fromJson(result.data?.data);
        isFollowing.value = userDetail.value.data?.isFollowing ?? false;
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFollow() async {
    if (userId.isEmpty) return;

    isFollowLoading.value = true;
    final wasFollowing = isFollowing.value;

    try {
      if (wasFollowing) {
        await unfollow(userId);
      } else {
        await follow(userId);
      }
    } finally {
      isFollowLoading.value = false;
    }
  }

  Future<void> follow(String userId) async {
    try {
      var result = await NetworkClient.instance.callApi(
        "/user/${userId}${ApiConstants.follow}",
        MethodType.post,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        isFollowing.value = true;
        userDetail.value = userDetail.value.copyWith(
          data: userDetail.value.data?.copyWith(isFollowing: true),
        );
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    }
  }

  Future<void> unfollow(String userId) async {
    try {
      var result = await NetworkClient.instance.callApi(
        "/user/${userId}${ApiConstants.unfollow}",
        MethodType.delete,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        isFollowing.value = false;
        userDetail.value = userDetail.value.copyWith(
          data: userDetail.value.data?.copyWith(isFollowing: false),
        );
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    }
  }

  getProductListApi({bool isInitial = true}) async {
    try {
      if (isInitial) {
        productsList.value = [];
        page.value = 1;
        nextPageStop.value = true;
        isLoading2.value = true;
      }
      if (nextPageStop.isTrue) {
        var result = await NetworkClient.instance.callApi(
          "${ApiConstants.product}?page=${page.value}&limit=20",
          baseUrlType: BaseUrl.base,
          MethodType.get,
        );
        if (result.isSuccess) {
          isLoading2.value = false;
          paginationLoading.value = false;

          var userProductListModel = UserProductListModel.fromJson(
            result.data?.data,
          );
          productsList.value += userProductListModel.data?.items ?? [];
          page.value = page.value + 1;
          if (productsList.isNotEmpty) {
            if (productsList.length.toString() ==
                userProductListModel.data?.total?.toString()) {
              nextPageStop.value = false;
            }
          }
        } else {
          isLoading2.value = false;
          paginationLoading.value = false;
          toast(result.error.toString());
        }
      }
    } catch (e) {
      isLoading2.value = false;
      paginationLoading.value = false;
      toast(e.toString());
    }
  }

  getOtherUserProductListApi({bool isInitial = true}) async {
    try {
      if (isInitial) {
        productsList.value = [];
        page.value = 1;
        nextPageStop.value = true;
        isLoading2.value = true;
      }
      if (nextPageStop.isTrue) {
        var result = await NetworkClient.instance.callApi(
          "${ApiConstants.otherProduct}/${userId}?page=${page.value}&limit=20",
          baseUrlType: BaseUrl.base,
          MethodType.get,
        );
        if (result.isSuccess) {
          isLoading2.value = false;
          paginationLoading.value = false;

          var userProductListModel = UserProductListModel.fromJson(
            result.data?.data,
          );
          productsList.value += userProductListModel.data?.items ?? [];
          page.value = page.value + 1;
          if (productsList.isNotEmpty) {
            if (productsList.length.toString() ==
                userProductListModel.data?.total?.toString()) {
              nextPageStop.value = false;
            }
          }
        } else {
          isLoading2.value = false;
          paginationLoading.value = false;
          toast(result.error.toString());
        }
      }
    } catch (e) {
      isLoading2.value = false;
      paginationLoading.value = false;
      toast(e.toString());
    }
  }
}
