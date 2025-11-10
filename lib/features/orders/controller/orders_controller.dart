import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/orders/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  final RxBool isLoading = false.obs;
  RxInt page = 1.obs;
  RxBool paginationLoading = false.obs;
  RxBool nextPageStop = true.obs;

  final RxList<OrderItem> orderList = <OrderItem>[].obs;
  final Rx<OrderModel> orderModel = OrderModel().obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    manageScrollController();
    getOrdersListApi();
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
            getOrdersListApi(isInitial: false);
          }
        }
      },
    );
  }

  getOrdersListApi({bool isInitial = true}) async {
    try {
      if (isInitial) {
        orderList.value = [];
        orderModel.value = OrderModel();
        page.value = 1;
        nextPageStop.value = true;
        isLoading.value = true;
      }
      if (nextPageStop.isTrue) {
        var result = await NetworkClient.instance.callApi(
          "${ApiConstants.orders}?page=${page.value}&limit=100",
          baseUrlType: BaseUrl.base,
          MethodType.get,
        );
        if (result.isSuccess) {
          isLoading.value = false;
          paginationLoading.value = false;
          orderModel.value = OrderModel.fromJson(result.data?.data);
          orderList.value += orderModel.value.orderItems ?? [];
          page.value = page.value + 1;
          if (orderList.isNotEmpty) {
            if (orderList.length.toString() ==
                orderModel.value.pagination?.total?.toString()) {
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
