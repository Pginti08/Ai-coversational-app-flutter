import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/product-detail/models/check_quotation_exists_model.dart';
import 'package:vousvous/features/quotations/screens/select_body_profile_bottom_sheet.dart';
import 'package:vousvous/routes/app_pages.dart';

class ProductDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isLoading2 = false.obs;
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

  Future<void> checkQuotationStatus(BuildContext context) async {
    try {
      isLoading2.value = true;
      var result = await NetworkClient.instance.callApi(
        isNotNullOrEmpty(productDetail.value.id)
            ? "${ApiConstants.checkQuotationExists}?productId=${productDetail.value.id}"
            : "${ApiConstants.checkQuotationExists}?image=${productDetail.value.image}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        var checkExistsQuotationModel =
            CheckQuotationExistsModel.fromJson(result.data?.data);
        if (checkExistsQuotationModel.data?.exists == true) {
          Get.toNamed(Routes.quotationChat, arguments: {
            "productId": productDetail.value.id,
            "quotationId": checkExistsQuotationModel.data?.quotationId,
          });
        } else {
          BlurBottomSheet().show<void>(
              height: MediaQuery.sizeOf(context).height * 0.8,
              context: context,
              borderColor: AppColors.whiteColor.withAlpha(40),
              backgroundColor: AppColors.scaffoldColor.withAlpha(200),
              barrierColor: AppColors.blackColor.withAlpha(50),
              blurStrength: 30,
              isCloseButton: true,
              child: SelectBodyProfileBottomSheet(
                productId: productDetail.value.id,
                image: productDetail.value.image,
                aiAnalysis: checkExistsQuotationModel.data?.aiAnalysis,
              ));
        }
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading2.value = false;
    }
  }
}
