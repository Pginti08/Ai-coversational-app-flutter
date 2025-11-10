import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/cart/models/cart_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartController extends GetxController {
  final RxBool isLoading = false.obs;
  RxInt page = 1.obs;
  RxBool paginationLoading = false.obs;
  RxBool nextPageStop = true.obs;

  final RxList<Cart> cartList = <Cart>[].obs;
  final Rx<CartModel> cartModel = CartModel().obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    manageScrollController();
    getCartListApi();
    super.onInit();
  }

  void manageScrollController() async {
    scrollController.addListener(
      () {
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
            getCartListApi(isInitial: false);
          }
        }
      },
    );
  }

  getCartListApi({bool isInitial = true}) async {
    try {
      if (isInitial) {
        cartList.value = [];
        cartModel.value = CartModel();
        page.value = 1;
        nextPageStop.value = true;
        isLoading.value = true;
      }
      if (nextPageStop.isTrue) {
        var result = await NetworkClient.instance.callApi(
          "${ApiConstants.cart}?page=${page.value}&limit=100",
          baseUrlType: BaseUrl.base,
          MethodType.get,
        );
        if (result.isSuccess) {
          isLoading.value = false;
          paginationLoading.value = false;
          cartModel.value = CartModel.fromJson(result.data?.data);
          cartList.value += cartModel.value.data?.items ?? [];
          page.value = page.value + 1;
          if (cartList.isNotEmpty) {
            if (cartList.length.toString() ==
                cartModel.value.data?.total?.toString()) {
              nextPageStop.value = false;
            }
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

  Future<void> removeFromCartApi(String? cartId) async {
    try {
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.cart}/${cartId}",
        MethodType.delete,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        getCartListApi();
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    }
  }
}
