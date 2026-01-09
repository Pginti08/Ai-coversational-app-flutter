import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';

class ProductDetailController extends GetxController {
  Product? productDetail;
  final RxBool isFollowing = false.obs;
  final RxBool isFollowLoading = false.obs;

  @override
  void onInit() {
    if (Get.arguments != null && Get.arguments["productDetail"] != null) {
      productDetail = Get.arguments["productDetail"];
      isFollowing.value = productDetail?.isFollowing ?? false;
    }
    super.onInit();
  }

  Future<void> toggleFollow() async {
    if (productDetail?.userId == null) return;

    isFollowLoading.value = true;
    final wasFollowing = isFollowing.value;

    try {
      if (wasFollowing) {
        await unfollow(productDetail!.userId!);
      } else {
        await follow(productDetail!.userId!);
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
        productDetail = productDetail?.copyWith(isFollowing: true);
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
        productDetail = productDetail?.copyWith(isFollowing: false);
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    }
  }
}
