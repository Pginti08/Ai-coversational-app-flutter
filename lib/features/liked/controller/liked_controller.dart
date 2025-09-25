import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/home/models/product_list_model.dart';
import 'package:ai_fashion/features/liked/models/liked_product_list_model.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LikedController extends GetxController {
  var currentCarouselIndex = 0.obs;
  final RxList<Product> remixProducts = <Product>[].obs;
  final RxBool isLoading = false.obs;
  RxInt page = 1.obs;
  RxBool paginationLoading = false.obs;
  RxBool nextPageStop = true.obs;

  final RxList<Product> likedProductsList = <Product>[].obs;

  final CarouselSliderController carouselController =
      CarouselSliderController();

  @override
  void onInit() {
    getLikedProductListApi();
    super.onInit();
  }

  getLikedProductListApi({bool isInitial = true}) async {
    try {
      if (isInitial) {
        likedProductsList.clear();
        page.value = 1;
        nextPageStop.value = true;
        isLoading.value = true;
      } else {
        paginationLoading.value = true;
      }

      if (nextPageStop.isTrue) {
        var result = await NetworkClient.instance.callApi(
          "${ApiConstants.getLikedProducts}?page=${page.value}&limit=20",
          baseUrlType: BaseUrl.base,
          MethodType.get,
        );
        if (result.isSuccess) {
          isLoading.value = false;
          paginationLoading.value = false;

          var likedProductListModel =
              LikedProductListModel.fromJson(result.data?.data);
          likedProductsList.addAll(likedProductListModel.data?.items ?? []);

          page.value = page.value + 1;

          if (likedProductsList.length.toString() ==
              likedProductListModel.data?.total?.toString()) {
            nextPageStop.value = false;
          }
        } else {
          isLoading.value = false;
          paginationLoading.value = false;
          toast(result.error.toString());
        }
      }
    } catch (e) {
      isLoading.value = false;
      paginationLoading.value = false;
      toast(e.toString());
    }
  }

  // Method to add current carousel item to remix products
  void addToRemix(CarouselSliderController carouselController) {
    if (likedProductsList.isNotEmpty &&
        currentCarouselIndex.value < likedProductsList.length) {
      final currentProduct = likedProductsList[currentCarouselIndex.value];

      // Avoid duplicates
      if (!remixProducts.any((product) => product.id == currentProduct.id)) {
        if (remixProducts.length < 4) {
          remixProducts.add(currentProduct);
        } else {
          toast("You can select maximum 4 images in Remix");
        }
      } else {
        toast("Already in Remix");
      }

      // Move to next index
      if (currentCarouselIndex.value < likedProductsList.length - 1) {
        currentCarouselIndex.value++;
        carouselController.animateToPage(
          currentCarouselIndex.value,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
      //else if (currentCarouselIndex.value == likedProductsList.length - 1) {
      //   currentCarouselIndex.value = 0;
      //   carouselController.animateToPage(
      //     currentCarouselIndex.value,
      //     duration: const Duration(milliseconds: 300),
      //     curve: Curves.easeInOut,
      //   );
      // }
    }
  }

  // Method to clear all remix products (optional)
  void clearRemixProducts() {
    remixProducts.clear();
  }
}
