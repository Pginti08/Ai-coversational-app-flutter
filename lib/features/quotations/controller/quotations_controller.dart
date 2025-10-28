import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/quotations/models/quotations_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuotationsController extends GetxController {
  final RxBool isLoading = false.obs;
  RxInt page = 1.obs;
  RxBool paginationLoading = false.obs;
  RxBool nextPageStop = true.obs;

  final RxList<Quotation> quotationList = <Quotation>[].obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    manageScrollController();
    getQuotationListApi();
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
            getQuotationListApi(isInitial: false);
          }
        }
      },
    );
  }

  getQuotationListApi({bool isInitial = true}) async {
    try {
      if (isInitial) {
        quotationList.value = [];
        page.value = 1;
        nextPageStop.value = true;
        isLoading.value = true;
      }
      if (nextPageStop.isTrue) {
        var result = await NetworkClient.instance.callApi(
          "${ApiConstants.quotations}?page=${page.value}&limit=20",
          baseUrlType: BaseUrl.base,
          MethodType.get,
        );
        if (result.isSuccess) {
          isLoading.value = false;
          paginationLoading.value = false;

          var quotationListModel = QuotationModel.fromJson(result.data?.data);
          quotationList.value += quotationListModel.data?.items ?? [];
          page.value = page.value + 1;
          if (quotationList.isNotEmpty) {
            if (quotationList.length.toString() ==
                quotationListModel.data?.total?.toString()) {
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
