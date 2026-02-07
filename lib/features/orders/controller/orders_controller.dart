import 'dart:async';
import 'dart:convert';

import 'package:eventflux/eventflux.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/features/orders/models/order_model.dart';

class OrdersController extends GetxController {
  // --- Reactive UI State ---
  final RxBool isLoading = false.obs;
  final RxBool paginationLoading = false.obs;
  final RxBool nextPageStop = true.obs;
  final RxList<OrderItem> orderList = <OrderItem>[].obs;
  final Rx<OrderModel> orderModel = OrderModel().obs;

  final ScrollController scrollController = ScrollController();

  // --- EventFlux State ---
  EventFlux? _eventFlux;
  int _currentLimit = 20;
  final int _limitIncrement = 20;

  // Debounce timer to prevent multiple rapid calls
  Timer? _debounceTimer;
  bool _isLoadingNextPage = false;

  @override
  void onInit() {
    super.onInit();
    fetchOrdersSSE(isInitial: true);
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
      debugPrint("\n🔔 === SCROLL END REACHED (ORDERS) ===");

      if (nextPageStop.value &&
          !paginationLoading.value &&
          !_isLoadingNextPage) {
        _isLoadingNextPage = true;
        paginationLoading.value = true;
        _currentLimit += _limitIncrement;

        // Scroll up to show loader
        _scrollToShowLoader();

        fetchOrdersSSE(isInitial: false);
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

      debugPrint(
          "📜 Scrolling up to show loader: $currentPosition → $targetPosition");

      scrollController.animateTo(
        targetPosition > 0 ? targetPosition : 0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> fetchOrdersSSE({bool isInitial = true}) async {
    try {
      debugPrint("\n🔄 === FETCH ORDERS SSE ===");
      debugPrint("📍 isInitial: $isInitial, Limit: $_currentLimit");

      if (isInitial) {
        _currentLimit = 20;
        _isLoadingNextPage = false;
        orderList.clear();
        nextPageStop.value = true;
        isLoading.value = true;
      }

      // 1. Prepare Connection
      _disconnectSSE();
      _eventFlux = EventFlux.spawn();

      final String? token =
          LocalStorageService.instance.getString(StorageConstants.accessToken);
      final String url =
          "${ApiConstants.baseURL}${ApiConstants.ordersStream}?page=1&limit=$_currentLimit";

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
      debugPrint("❌ Exception in fetchOrdersSSE: $e");
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
    debugPrint("\n📊 === PROCESS INITIAL DATA (ORDERS) ===");

    try {
      final incoming = OrderModel.fromJson(data);
      final items = incoming.data?.orderItems ?? [];
      final total = incoming.data?.pagination?.total ?? 0;

      debugPrint("📋 Response details:");
      debugPrint("   - Items received: ${items.length}");
      debugPrint("   - Total available: $total");
      debugPrint("   - Current limit: $_currentLimit");
      debugPrint("   - List size before: ${orderList.length}");

      // Always replace the entire list with fresh data
      orderList.assignAll(items);
      debugPrint("✅ Replaced list with ${items.length} items");

      debugPrint("📋 List size after: ${orderList.length}");

      // Pagination Logic - Check if we have more data to load
      if (orderList.length >= total) {
        nextPageStop.value = false;
        debugPrint("🛑 PAGINATION STOPPED");
        debugPrint("   - Loaded: ${orderList.length}/$total items");
      } else {
        nextPageStop.value = true;
        debugPrint("➡️ PAGINATION ENABLED");
        debugPrint("   - Loaded: ${orderList.length}/$total items");
        debugPrint(
            "   - Next limit will be: ${_currentLimit + _limitIncrement}");
      }

      _isLoadingNextPage = false;
      orderList.refresh();

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
      final updateModel = OrderModel.fromJson(data);
      final updates = updateModel.data?.orderItems ?? [];

      debugPrint("📋 ${updates.length} items to update");

      for (var newItem in updates) {
        final idx = orderList.indexWhere((item) => item.id == newItem.id);
        if (idx != -1) {
          orderList[idx] = newItem;
          debugPrint("✅ Updated item at index $idx (ID: ${newItem.id})");
        } else {
          // Add new order to the top
          orderList.insert(0, newItem);
          debugPrint("✅ Inserted new order at top (ID: ${newItem.id})");
        }
      }
      orderList.refresh();
    } catch (e) {
      debugPrint("❌ Error in _processUpdate: $e");
    }
  }

  void _handleError(dynamic error) {
    debugPrint("❌ === HANDLE ERROR ===");
    debugPrint("Error: $error");
    _stopLoaders();
    _isLoadingNextPage = false;
    // toast("Live updates temporarily unavailable");
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
}
