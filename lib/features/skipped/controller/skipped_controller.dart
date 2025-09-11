import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/home/models/product_list_model.dart';
import 'package:ai_fashion/features/skipped/models/skip_product_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SkippedController extends GetxController {
  final RxBool isLoading = false.obs;
  RxInt page = 1.obs;
  RxBool paginationLoading = false.obs;
  RxBool nextPageStop = true.obs;

  final RxList<Product> skipProductsList = <Product>[].obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    manageScrollController();
    getSkipProductListApi();
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
            getSkipProductListApi(isInitial: false);
          }
        }
      },
    );
  }

  getSkipProductListApi({bool isInitial = true}) async {
    try {
      if (isInitial) {
        skipProductsList.value = [];
        page.value = 1;
        nextPageStop.value = true;
        isLoading.value = true;
      }
      if (nextPageStop.isTrue) {
        var result = await NetworkClient.instance.callApi(
          "${ApiConstants.getSkipProducts}?page=${page.value}&limit=20",
          baseUrlType: BaseUrl.base,
          MethodType.get,
        );
        if (result.isSuccess) {
          isLoading.value = false;
          paginationLoading.value = false;

          var skipProductListModel =
              SkipProductListModel.fromJson(result.data?.data);
          skipProductsList.value += skipProductListModel.data?.items ?? [];
          page.value = page.value + 1;
          if (skipProductsList.isNotEmpty) {
            if (skipProductsList.length.toString() ==
                skipProductListModel.data?.total?.toString()) {
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
    }
  }
}
