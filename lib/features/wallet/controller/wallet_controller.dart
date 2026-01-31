import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/utils/extensions.dart';
import 'package:vousvous/features/wallet/models/wallet_balance_model.dart';
import 'package:vousvous/features/wallet/models/wallet_history_model.dart';

class WalletController extends GetxController {
  final RxBool isLoading = true.obs;
  final Rx<WalletBalanceData?> walletBalance = Rx<WalletBalanceData?>(null);

  // History related
  final RxList<WalletHistoryItem> historyItems = <WalletHistoryItem>[].obs;
  final RxBool isHistoryLoading = true.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool hasMore = true.obs;
  int _currentPage = 1;
  static const int _limit = 20;

  @override
  void onInit() {
    super.onInit();
    fetchWalletBalance();
    fetchHistory();
  }

  Future<void> fetchWalletBalance() async {
    isLoading.value = true;

    final result = await NetworkClient.instance.callApi(
      ApiConstants.walletBalance,
      MethodType.get,
      baseUrlType: BaseUrl.base,
    );

    if (result.isSuccess && result.data != null) {
      try {
        final model = WalletBalanceModel.fromJson(result.data!.data);
        if (model.success == true && model.data != null) {
          walletBalance.value = model.data;
        }
      } catch (e) {
        debugPrint('Error parsing wallet balance: $e');
      }
    }

    isLoading.value = false;
  }

  Future<void> fetchHistory({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      historyItems.clear();
      hasMore.value = true;
    }

    if (!hasMore.value && !refresh) return;

    if (_currentPage == 1) {
      isHistoryLoading.value = true;
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

    isHistoryLoading.value = false;
    isLoadingMore.value = false;
  }

  void loadMore() {
    if (!isLoadingMore.value && hasMore.value) {
      fetchHistory();
    }
  }

  Future<void> refreshAll() async {
    await fetchWalletBalance();
    await fetchHistory(refresh: true);
  }

  /// Format balance with 2 decimal places, removing trailing zeros
  String get formattedBalance {
    final balance = walletBalance.value?.balanceCU ?? 0.0;
    return balance.toFormattedCoins();
  }

  /// Calculate rupee value (1 credit = ₹100)
  String get rupeeValue {
    final balance = walletBalance.value?.balanceCU ?? 0.0;
    final rupees = balance * 100;
    return rupees.toFormattedPrice();
  }
}
