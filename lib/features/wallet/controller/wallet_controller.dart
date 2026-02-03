import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/utils/extensions.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/wallet/models/wallet_balance_model.dart';
import 'package:vousvous/features/wallet/models/wallet_history_model.dart';

class WalletController extends GetxController {
  final RxBool isLoading = true.obs;
  final Rx<WalletBalanceData?> walletBalance = Rx<WalletBalanceData?>(null);

  // History related
  final RxList<WalletHistory> historyItems = <WalletHistory>[].obs;
  final RxBool isHistoryLoading = true.obs;

  RxInt page = 1.obs;
  RxBool paginationLoading = false.obs;
  RxBool nextPageStop = true.obs;

  final ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    manageScrollController();
    fetchWalletBalance();
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

  Future<void> fetchHistory({bool isInitial = true}) async {
    try {
      if (isInitial) {
        historyItems.clear();
        page.value = 1;
        nextPageStop.value = true;
        isHistoryLoading.value = true;
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
          isHistoryLoading.value = false;
          paginationLoading.value = false;

          final model = WalletHistoryModel.fromJson(result.data!.data);
          if (model.success == true && model.data != null) {
            final newItems = model.data!.items ?? [];
            historyItems.addAll(newItems);

            page.value = page.value + 1;

            if (historyItems.isNotEmpty) {
              // Check total against current list length to determine if we should stop
              if (historyItems.length.toString() ==
                  model.data?.total?.toString()) {
                nextPageStop.value = false;
              }
            } else {
              // If list is empty, stop
              nextPageStop.value = false;
            }
          }
        } else {
          isHistoryLoading.value = false;
          paginationLoading.value = false;
          toast(result.error.toString());
        }
      }
    } catch (e) {
      isHistoryLoading.value = false;
      paginationLoading.value = false;
      toast(e.toString());
      debugPrint('Error parsing wallet history: $e');
    }
  }

  Future<void> refreshAll() async {
    await fetchWalletBalance();
    await fetchHistory(isInitial: true);
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
