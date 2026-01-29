import 'package:carousel_slider/carousel_controller.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/liked/models/liked_product_list_model.dart';

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

  // Check if maximum remix items are selected
  bool get isRemixAtMaxCapacity => remixProducts.length >= 4;

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

          var likedProductListModel = LikedProductListModel.fromJson(
            result.data?.data,
          );
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
  void addToRemix() {
    if (likedProductsList.isNotEmpty &&
        currentCarouselIndex.value < likedProductsList.length) {
      final currentProduct = likedProductsList[currentCarouselIndex.value];

      // Check if already at max capacity - silently ignore (button is hidden anyway)
      if (isRemixAtMaxCapacity) {
        return; // Don't add, don't show toast
      }

      // Avoid duplicates
      if (!remixProducts.any((product) => product.id == currentProduct.id)) {
        remixProducts.add(currentProduct);

        // Move to next index only if we successfully added
        // if (currentCarouselIndex.value < likedProductsList.length - 1) {
        //   currentCarouselIndex.value++;
        //   carouselController.animateToPage(
        //     currentCarouselIndex.value,
        //     duration: const Duration(milliseconds: 300),
        //     curve: Curves.easeInOut,
        //   );
        // }
      } else {
        toast("Already in Remix", type: ToastType.warning);
      }
    }
  }

  void removeFromRemix() {
    if (likedProductsList.isNotEmpty &&
        currentCarouselIndex.value < likedProductsList.length) {
      final currentProduct = likedProductsList[currentCarouselIndex.value];

      // Check if product is in remix
      if (remixProducts.any((product) => product.id == currentProduct.id)) {
        remixProducts.removeWhere((product) => product.id == currentProduct.id);
      } else {
        toast("Not in Remix");
      }

      // Move to next item safely
      // if (currentCarouselIndex.value < likedProductsList.length - 1) {
      //   currentCarouselIndex.value++;
      // } else if (currentCarouselIndex.value > 0) {
      //   // If it's last item, move to previous
      //   currentCarouselIndex.value--;
      // }

      // carouselController.animateToPage(
      //   currentCarouselIndex.value,
      //   duration: const Duration(milliseconds: 300),
      //   curve: Curves.easeInOut,
      // );
    }
  }

  // Method to clear all remix products (optional)
  void clearRemixProducts() {
    remixProducts.clear();
  }
}
