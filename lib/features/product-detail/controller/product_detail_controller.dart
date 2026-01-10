import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';

class ProductDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isFollowing = false.obs;
  final RxBool isFollowLoading = false.obs;
  Rx<Product> productDetail = Product().obs;

  @override
  void onInit() {
    if (Get.arguments != null && Get.arguments["productDetail"] != null) {
      productDetail.value = Get.arguments["productDetail"];
    }
    super.onInit();
  }

  void onReady() {
    getProductDetail();
    super.onReady();
  }

  Future<void> toggleFollow() async {
    if (productDetail.value.userId == null) return;

    isFollowLoading.value = true;
    final wasFollowing = isFollowing.value;

    try {
      if (wasFollowing) {
        await unfollow(productDetail.value.userId!);
      } else {
        await follow(productDetail.value.userId!);
      }
    } finally {
      isFollowLoading.value = false;
    }
  }

  Future<void> getProductDetail() async {
    try {
      isLoading.value = true;
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.product}/${productDetail.value.id}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        isFollowing.value = true;
        productDetail.value = Product.fromJson(result.data?.data["data"]);
        isFollowing.value = productDetail.value.isFollowing ?? false;
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
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
        productDetail.value = productDetail.value.copyWith(isFollowing: true);
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
        productDetail.value = productDetail.value.copyWith(isFollowing: false);
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    }
  }
}
