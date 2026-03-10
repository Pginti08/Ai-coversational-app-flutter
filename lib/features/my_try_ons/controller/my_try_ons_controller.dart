import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/my_try_ons/models/virtual_try_on_list_model.dart';

class MyTryOnsController extends GetxController {
  final RxBool isLoading = false.obs;
  RxInt page = 1.obs;
  RxBool paginationLoading = false.obs;
  RxBool nextPageStop = true.obs;

  final RxList<VirtualTryOn> myTryOnsList = <VirtualTryOn>[].obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    manageScrollController();
    getMyTryOnsListApi();
    super.onInit();
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
          getMyTryOnsListApi(isInitial: false);
        }
      }
    });
  }

  getMyTryOnsListApi({bool isInitial = true}) async {
    try {
      if (isInitial) {
        myTryOnsList.value = [];
        page.value = 1;
        nextPageStop.value = true;
        isLoading.value = true;
      }
      if (nextPageStop.isTrue) {
        var result = await NetworkClient.instance.callApi(
          "${ApiConstants.myTryOns}?page=${page.value}&limit=20",
          baseUrlType: BaseUrl.ai,
          MethodType.get,
        );
        if (result.isSuccess) {
          isLoading.value = false;
          paginationLoading.value = false;

          var virtualTryOnListModel = VirtualTryOnListModel.fromJson(
            result.data?.data,
          );
          myTryOnsList.value += virtualTryOnListModel.data?.items ?? [];
          page.value = page.value + 1;
          if (myTryOnsList.isNotEmpty) {
            if (myTryOnsList.length.toString() ==
                virtualTryOnListModel.data?.items?.length.toString()) {
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
}
