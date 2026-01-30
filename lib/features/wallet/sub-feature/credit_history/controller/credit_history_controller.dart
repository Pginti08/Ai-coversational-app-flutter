import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/features/wallet/models/wallet_history_model.dart';

class CreditHistoryController extends GetxController {
  final RxList<WalletHistoryItem> historyItems = <WalletHistoryItem>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  int _currentPage = 1;
  static const int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
  }

  Future<void> fetchHistory({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      historyItems.clear();
      hasMore.value = true;
    }

    if (!hasMore.value && !refresh) return;

    if (_currentPage == 1) {
      isLoading.value = true;
    } else {
      isLoadingMore.value = true;
    }

    final result = await NetworkClient.instance.callApi(
      ApiConstants.walletHistory,
      MethodType.get,
      baseUrlType: BaseUrl.base,
      params: {
        'page': _currentPage,
        'limit': _limit,
      },
    );

    if (result.isSuccess && result.data != null) {
      try {
        final model = WalletHistoryModel.fromJson(result.data!.data);
        if (model.success == true && model.data != null) {
          final newItems = model.data!.items ?? [];
          historyItems.addAll(newItems);

          // Update pagination state
          hasMore.value = model.data!.hasMore;
          _currentPage++;
        }
      } catch (e) {
        debugPrint('Error parsing wallet history: $e');
      }
    }

    isLoading.value = false;
    isLoadingMore.value = false;
  }

  void loadMore() {
    if (!isLoadingMore.value && hasMore.value) {
      fetchHistory();
    }
  }
}
