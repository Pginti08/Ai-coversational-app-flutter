import 'dart:async';
import 'dart:convert';

import 'package:eventflux/eventflux.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/quotations/models/quotations_model.dart';

class QuotationsController extends GetxController {
  // --- Reactive UI State ---
  final RxBool isLoading = false.obs;
  final RxBool isLoading2 = false.obs;
  final RxBool paginationLoading = false.obs;
  final RxBool nextPageStop = true.obs;
  final RxList<Quotation> quotationList = <Quotation>[].obs;

  final ScrollController scrollController = ScrollController();

  // --- EventFlux State ---
  EventFlux? _eventFlux;
  int _currentLimit = 7;
  final int _limitIncrement = 7;

  // Debounce timer to prevent multiple rapid calls
  Timer? _debounceTimer;
  bool _isLoadingNextPage = false;

  @override
  void onInit() {
    super.onInit();
    fetchQuotationsSSE(isInitial: true);
  }

  @override
  void onClose() {
    _disconnectSSE();
    _debounceTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  // Method to be called from UI when scroll reaches end
  void onScrollEndReached() {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set a new timer to debounce rapid scroll events
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      debugPrint("\n🔔 === SCROLL END REACHED ===");

      if (nextPageStop.value &&
          !paginationLoading.value &&
          !_isLoadingNextPage) {
        _isLoadingNextPage = true;
        paginationLoading.value = true;
        _currentLimit += _limitIncrement;

        // Scroll up to show loader
        _scrollToShowLoader();

        fetchQuotationsSSE(isInitial: false);
      } else {
        debugPrint("⚠️ Pagination blocked:");
        if (!nextPageStop.value) debugPrint("   - No more data available");
        if (paginationLoading.value) debugPrint("   - Already loading");
        if (_isLoadingNextPage) debugPrint("   - Load in progress");
      }
    });
  }

  void _scrollToShowLoader() {
    // Scroll up by 100 pixels to make the loader visible
    if (scrollController.hasClients) {
      final currentPosition = scrollController.position.pixels;
      final targetPosition = currentPosition + 300;

      scrollController.animateTo(
        targetPosition > 0 ? targetPosition : 0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> fetchQuotationsSSE({bool isInitial = true}) async {
    try {
      debugPrint("\n🔄 === FETCH QUOTATIONS SSE ===");
      debugPrint("📍 isInitial: $isInitial, Limit: $_currentLimit");

      if (isInitial) {
        _currentLimit = 7;
        _isLoadingNextPage = false;
        quotationList.clear();
        nextPageStop.value = true;
        isLoading.value = true;
      }

      // 1. Prepare Connection
      _disconnectSSE();
      _eventFlux = EventFlux.instance;

      final String? token =
          LocalStorageService.instance.getString(StorageConstants.accessToken);
      final String url =
          "${ApiConstants.baseURL}${ApiConstants.quotationsStream}?page=1&limit=$_currentLimit";

      debugPrint("🌐 Connecting to: $url");

      // 2. Connect using EventFlux
      _eventFlux?.connect(
        EventFluxConnectionType.get,
        url,
        header: {
          'Authorization': 'Bearer $token',
        },
        onSuccessCallback: (EventFluxResponse? response) {
          debugPrint("✅ SSE Connection established");
          response?.stream?.listen(
            (EventFluxData event) {
              if (event.data.isNotEmpty) {
                debugPrint("📨 Received SSE data");
                _handleIncomingData(event.data, isInitial);
              }
            },
            onError: (error) {
              debugPrint("❌ Stream error: $error");
              _handleError(error);
            },
            onDone: () {
              debugPrint("✅ SSE Stream completed");
              _stopLoaders();
            },
          );
        },
        onError: (EventFluxException error) {
          debugPrint("❌ Connection error: ${error.message}");
          _handleError(error);
        },
      );
    } catch (e, stackTrace) {
      debugPrint("❌ Exception in fetchQuotationsSSE: $e");
      debugPrint("Stack: $stackTrace");
      _handleError(e);
    }
  }

  void _handleIncomingData(String rawData, bool isInitialLoad) {
    try {
      debugPrint("🔍 Parsing SSE data...");
      final decoded = jsonDecode(rawData);
      final String type = decoded['type'];

      debugPrint("🏷️ Event type: $type");

      _stopLoaders();

      if (type == 'initial') {
        _processInitial(decoded);
      } else if (type == 'update') {
        _processUpdate(decoded);
      } else {
        debugPrint("⚠️ Unknown event type: $type");
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Parsing error: $e");
      debugPrint("Stack: $stackTrace");
      _stopLoaders();
    }
  }

  void _processInitial(Map<String, dynamic> data) {
    debugPrint("\n📊 === PROCESS INITIAL DATA ===");

    try {
      final incoming = QuotationModel.fromJson(data);
      final items = incoming.data?.items ?? [];
      final total = incoming.data?.total ?? 0;

      debugPrint("📋 Response details:");
      debugPrint("   - Items received: ${items.length}");
      debugPrint("   - Total available: $total");
      debugPrint("   - Current limit: $_currentLimit");
      debugPrint("   - List size before: ${quotationList.length}");

      // Always replace the entire list with fresh data
      quotationList.assignAll(items);
      debugPrint("✅ Replaced list with ${items.length} items");

      debugPrint("📋 List size after: ${quotationList.length}");

      // Pagination Logic - Check if we have more data to load
      if (quotationList.length >= total) {
        nextPageStop.value = false;
        debugPrint("🛑 PAGINATION STOPPED");
        debugPrint("   - Loaded: ${quotationList.length}/$total items");
      } else {
        nextPageStop.value = true;
        debugPrint("➡️ PAGINATION ENABLED");
        debugPrint("   - Loaded: ${quotationList.length}/$total items");
        debugPrint(
            "   - Next limit will be: ${_currentLimit + _limitIncrement}");
      }

      _isLoadingNextPage = false;
      quotationList.refresh();

      debugPrint("✅ Process initial completed");
    } catch (e, stackTrace) {
      debugPrint("❌ Error in _processInitial: $e");
      debugPrint("Stack: $stackTrace");
      _isLoadingNextPage = false;
    }
  }

  void _processUpdate(Map<String, dynamic> data) {
    debugPrint("🔄 Processing update event");

    try {
      final updateModel = QuotationModel.fromJson(data);
      final updates = updateModel.data?.items ?? [];

      debugPrint("📋 ${updates.length} items to update");

      for (var newItem in updates) {
        final idx = quotationList.indexWhere((item) => item.id == newItem.id);
        if (idx != -1) {
          quotationList[idx] = newItem;
          debugPrint("✅ Updated item at index $idx (ID: ${newItem.id})");
        } else {
          // Add new item to the top
          quotationList.insert(0, newItem);
          debugPrint("✅ Inserted new item at top (ID: ${newItem.id})");
        }
      }
      quotationList.refresh();
    } catch (e) {
      debugPrint("❌ Error in _processUpdate: $e");
    }
  }

  void _handleError(dynamic error) {
    debugPrint("❌ === HANDLE ERROR ===");
    debugPrint("Error: $error");
    _stopLoaders();
    _isLoadingNextPage = false;
    toast("Live updates temporarily unavailable");
  }

  void _disconnectSSE() {
    if (_eventFlux != null) {
      debugPrint("🔌 Disconnecting SSE");
      _eventFlux?.disconnect();
      _eventFlux = null;
    }
  }

  void _stopLoaders() {
    debugPrint("⏹️ Stopping loaders");
    isLoading.value = false;
    paginationLoading.value = false;
  }

  Future<void> deleteQuotation(String? id) async {
    try {
      debugPrint("\n🗑️ === DELETE QUOTATION ===");
      debugPrint("ID: $id");

      isLoading2.value = true;
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.quotations}/$id",
        MethodType.delete,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        debugPrint("✅ API delete successful");

        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        final countBefore = quotationList.length;
        quotationList.removeWhere((item) => item.id == id);
        final countAfter = quotationList.length;

        quotationList.refresh();

        debugPrint("📊 List: $countBefore → $countAfter items");

        toast("Quotation deleted successfully", type: ToastType.success);
      } else {
        debugPrint("❌ API delete failed: ${result.error}");
        toast(result.error.toString());
      }
    } catch (e, stackTrace) {
      debugPrint("❌ Exception in deleteQuotation: $e");
      debugPrint("Stack: $stackTrace");
      toast(e.toString());
    } finally {
      isLoading2.value = false;
    }
  }
}
