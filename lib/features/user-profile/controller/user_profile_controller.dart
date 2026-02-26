import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/home/models/user_detail_model.dart';
import 'package:vousvous/features/user-profile/controller/posts_view_controller.dart';
import 'package:vousvous/features/user-profile/models/follower_list_model.dart';
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

  final RxList<Product> posts = <Product>[].obs;
  // 💎 Global session cache (STATIC) to ensure all instances share the same memory
  static final RxSet<String> sessionLikedIds = <String>{}.obs;
  static final RxSet<String> sessionUnlikedIds = <String>{}.obs;

  // Follower list variables
  final RxList<Follower> followers = <Follower>[].obs;
  final RxBool isFollowersLoading = false.obs;
  RxInt followersPage = 1.obs;
  RxBool followersNextPageStop = true.obs;
  RxBool followersPaginationLoading = false.obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    // 🛡️ Load persistent likes
    sessionLikedIds.addAll(LocalStorageService.instance.getLikedIds());
    sessionUnlikedIds.addAll(LocalStorageService.instance.getUnlikedIds());
    debugPrint("📥 Loaded ${sessionLikedIds.length} liked IDs from Disk");

    if (Get.arguments != null && Get.arguments["userId"] != null) {
      userId = Get.arguments["userId"];
      if (userId != LocalStorageService.instance.userInfo.value.data?.id) {
        isYou = false;
      } else {
        isYou = true;
      }
    }

    if (isYou) {
      getUserDetail();
      getProductListApi();
    } else {
      getOtherUserDetail();
      getOtherUserProductListApi();
    }
    manageScrollController();
  }

  // 💾 Helper to update global session and disk
  static void updateLikeSession(String productId, bool isLiked) {
    if (isLiked) {
      sessionLikedIds.add(productId);
      sessionUnlikedIds.remove(productId);
    } else {
      sessionUnlikedIds.add(productId);
      sessionLikedIds.remove(productId);
    }
    // Save to Disk concurrently
    LocalStorageService.instance.saveLikedIds(sessionLikedIds.toList());
    LocalStorageService.instance.saveUnlikedIds(sessionUnlikedIds.toList());
    debugPrint("💾 Persistent Save: $productId isLiked=$isLiked");
  }

  @override
  void onReady() {
    // The logic previously here has been moved to onInit as per instruction.
    // Keeping super.onReady() call.
    super.onReady();
  }

  void manageScrollController() async {
    scrollController.addListener(() {
      if (scrollController.position.maxScrollExtent ==
          scrollController.position.pixels) {
        if (nextPageStop.isTrue &&
            paginationLoading.isFalse &&
            posts.isNotEmpty) {
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

  Future<void> getUserDetail({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;

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
      if (showLoader) isLoading.value = false;
    }
  }

  Future<void> getOtherUserDetail({bool showLoader = true}) async {
    try {
      if (showLoader) isLoading.value = true;

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
      if (showLoader) isLoading.value = false;
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
        if (isYou) {
          getUserDetail(showLoader: false);
        } else {
          getOtherUserDetail(showLoader: false);
        }
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
        if (isYou) {
          getUserDetail(showLoader: false);
        } else {
          getOtherUserDetail(showLoader: false);
        }
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
        posts.value = [];
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
          final newItems = userProductListModel.data?.items ?? [];

          // 🛡️ Apply session-persistent likes/unlikes
          debugPrint(
              "🔍 SYNC: Checking ${newItems.length} items. Session Likes: ${UserProfileController.sessionLikedIds}");
          for (int i = 0; i < newItems.length; i++) {
            final id = newItems[i].id;
            if (id != null) {
              if (UserProfileController.sessionLikedIds.contains(id)) {
                debugPrint("✅ PERSISTING LIKE FOR: $id");
                newItems[i] = newItems[i].copyWith(
                  isLiked: true,
                  likesCount: (newItems[i].isLiked == true)
                      ? newItems[i].likesCount
                      : (newItems[i].likesCount ?? 0) + 1,
                );
              } else if (UserProfileController.sessionUnlikedIds.contains(id)) {
                newItems[i] = newItems[i].copyWith(
                  isLiked: false,
                  likesCount: (newItems[i].isLiked == false)
                      ? newItems[i].likesCount
                      : ((newItems[i].likesCount ?? 0) > 0
                          ? (newItems[i].likesCount! - 1)
                          : 0),
                );
              }
            }
          }

          posts.addAll(newItems);

          if (Get.isRegistered<PostsViewController>()) {
            final postsController = Get.find<PostsViewController>();
            if (isInitial) {
              postsController.posts.value = List<Product>.from(newItems);
            } else {
              postsController.posts.addAll(newItems);
            }
          }
          page.value = page.value + 1;
          if (posts.isNotEmpty) {
            if (posts.length.toString() ==
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
        posts.value = [];
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
          final newItems = userProductListModel.data?.items ?? [];

          // 🛡️ Apply session-persistent likes/unlikes
          debugPrint(
              "🔍 SYNC (Other): Checking ${newItems.length} items. Session Likes: ${UserProfileController.sessionLikedIds}");
          for (int i = 0; i < newItems.length; i++) {
            final id = newItems[i].id;
            if (id != null) {
              if (UserProfileController.sessionLikedIds.contains(id)) {
                debugPrint("✅ PERSISTING LIKE FOR: $id");
                newItems[i] = newItems[i].copyWith(
                  isLiked: true,
                  likesCount: (newItems[i].isLiked == true)
                      ? newItems[i].likesCount
                      : (newItems[i].likesCount ?? 0) + 1,
                );
              } else if (UserProfileController.sessionUnlikedIds.contains(id)) {
                newItems[i] = newItems[i].copyWith(
                  isLiked: false,
                  likesCount: (newItems[i].isLiked == false)
                      ? newItems[i].likesCount
                      : ((newItems[i].likesCount ?? 0) > 0
                          ? (newItems[i].likesCount! - 1)
                          : 0),
                );
              }
            }
          }

          posts.addAll(newItems);

          if (Get.isRegistered<PostsViewController>()) {
            final postsController = Get.find<PostsViewController>();
            if (isInitial) {
              postsController.posts.value = List<Product>.from(newItems);
            } else {
              postsController.posts.addAll(newItems);
            }
          }
          page.value = page.value + 1;
          if (posts.isNotEmpty) {
            if (posts.length.toString() ==
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

  Future<void> getFollowersApi(
      {bool isInitial = true, String type = 'followers'}) async {
    try {
      if (isInitial) {
        followers.clear();
        followersPage.value = 1;
        followersNextPageStop.value = true;
        isFollowersLoading.value = true;
      }

      if (followersNextPageStop.isTrue) {
        String targetUserId = userId;
        if (targetUserId.isEmpty && isYou) {
          targetUserId =
              LocalStorageService.instance.userInfo.value.data?.id ?? "";
        }

        if (targetUserId.isEmpty) {
          isFollowersLoading.value = false;
          return;
        }

        String endpoint = type == 'following'
            ? ApiConstants.following
            : ApiConstants.followers;

        var result = await NetworkClient.instance.callApi(
          "/user/${targetUserId}${endpoint}?page=${followersPage.value}&limit=20",
          MethodType.get,
          baseUrlType: BaseUrl.base,
        );

        if (result.isSuccess) {
          isFollowersLoading.value = false;
          followersPaginationLoading.value = false;

          var followerListModel = FollowerListModel.fromJson(result.data?.data);

          List<Follower> fetchedList = followerListModel.data ?? [];

          // IMPORTANT: The API's isFollowing field should indicate whether the LOGGED-IN user
          // is following each person in the list, NOT whether the profile owner is following them.
          //
          // Special case: If viewing MY OWN following list, everyone is followed by me by definition.
          if (type == 'following' && isYou) {
            fetchedList = fetchedList.map((e) {
              e.isFollowing = true;
              return e;
            }).toList();
          }
          // For all other cases (followers of anyone, or following of other users),
          // we trust the API's isFollowing field which should reflect the logged-in user's status.

          followers.value += fetchedList;

          followersPage.value = followersPage.value + 1;

          if (followers.isNotEmpty) {
            if (followers.length.toString() ==
                followerListModel.pagination?.total?.toString()) {
              followersNextPageStop.value = false;
            }
          }
        } else {
          isFollowersLoading.value = false;
          followersPaginationLoading.value = false;
          toast(result.error ?? "Failed to load followers");
        }
      }
    } catch (e) {
      isFollowersLoading.value = false;
      followersPaginationLoading.value = false;
      toast(e.toString());
    }
  }

  Future<void> toggleFollowFromList(int index) async {
    if (index >= followers.length) return;

    final follower = followers[index];
    if (follower.id == null) return;

    final wasFollowing = follower.isFollowing ?? false;

    // Optimistic update
    followers[index] = Follower(
      id: follower.id,
      name: follower.name,
      image: follower.image,
      bio: follower.bio,
      isFollowing: !wasFollowing,
    );
    followers.refresh(); // Ensure UI updates

    try {
      if (wasFollowing) {
        await unfollow(follower.id!);
      } else {
        await follow(follower.id!);
      }
    } catch (e) {
      // Check for specific backend errors indicating state mismatch
      final errorMsg = e.toString().toLowerCase();
      if (!wasFollowing && errorMsg.contains("already following")) {
        // We tried to follow, but backend says we already are.
        // The optimistic update (setting isFollowing = true) was actually correct in aligning with server state.
        // So we do NOT revert. We just update the ID if needed (unlikely).
        // Optionally show a clearer message or nothing.
        // toast("Synced: You are following this user.");
      } else if (wasFollowing && errorMsg.contains("not following")) {
        // We tried to unfollow, but backend says we aren't following.
        // Optimistic update (setting isFollowing = false) was correct.
        // Do NOT revert.
      } else {
        // Revert on actual failure
        followers[index] = follower;
        followers.refresh();
        toast("Action failed: ${e.toString()}");
      }
    }
  }
}
