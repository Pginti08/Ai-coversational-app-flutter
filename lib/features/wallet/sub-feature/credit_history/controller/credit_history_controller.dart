import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/wallet/models/wallet_history_model.dart';

class CreditHistoryController extends GetxController {
  final RxList<WalletHistory> historyItems = <WalletHistory>[].obs;
  final RxBool isLoading = true.obs;

  RxInt page = 1.obs;
  RxBool paginationLoading = false.obs;
  RxBool nextPageStop = true.obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    manageScrollController();
    fetchHistory();
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
          fetchHistory(isInitial: false);
        }
      }
    });
  }

  Future<void> fetchHistory({bool isInitial = true}) async {
    try {
      if (isInitial) {
        historyItems.clear();
        page.value = 1;
        nextPageStop.value = true;
        isLoading.value = true;
      }

      if (nextPageStop.isTrue) {
        final result = await NetworkClient.instance.callApi(
          ApiConstants.walletHistory,
          MethodType.get,
          baseUrlType: BaseUrl.base,
          params: {
            'page': page.value,
            'limit': 20,
          },
        );

        if (result.isSuccess && result.data != null) {
          isLoading.value = false;
          paginationLoading.value = false;

          final model = WalletHistoryModel.fromJson(result.data!.data);
          if (model.success == true && model.data != null) {
            final newItems = model.data!.items ?? [];
            historyItems.addAll(newItems);

            page.value = page.value + 1;

            if (historyItems.isNotEmpty) {
              if (historyItems.length.toString() ==
                  model.data?.total?.toString()) {
                nextPageStop.value = false;
              }
            } else {
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
      debugPrint('Error parsing wallet history: $e');
    }
  }
}
