import 'dart:developer' show log;

import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/constants/storage_constants.dart';
import 'package:ai_fashion/core/services/local_storage_service.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/quotation-chat/models/analyze_dress_model.dart';
import 'package:ai_fashion/features/quotation-chat/models/final_quotation_model.dart';
import 'package:ai_fashion/features/quotation-chat/models/quotation_chat_history_model.dart';
import 'package:ai_fashion/features/quotation-chat/widgets/chat_actions_buttons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wakelock_plus/wakelock_plus.dart';

class QuotationChatController extends GetxController {
  String imageUrl = "";
  String productId = "";
  final RxBool isDrawerOpen = false.obs;
  final typeFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  final RxBool loader = false.obs;
  final RxBool loader1 = false.obs;
  final Rx<AnalyzeDressModel> analyzeDressModel = AnalyzeDressModel().obs;

  String quotationId = "";

  RxInt page = 1.obs;
  RxBool paginationLoading = false.obs;
  RxBool nextPageStop = true.obs;
  QuotationChatHistoryModel quotationChatHistoryModel =
      QuotationChatHistoryModel();
  IO.Socket? socket;

  final RxBool isThinking = false.obs;
  final RxBool isNewChat = true.obs;

  final Rx<String?> thinkingMessage = Rx<String?>(null);

  // Chat messages list
  final RxList<Message> messages = <Message>[].obs;

  //chat actions
  final RxList<Option> buttonOptions = <Option>[].obs;
  final RxBool showBodyProfile = false.obs;
  final RxBool showBulkQuantity = false.obs;
  final Rxn<FinalQuotationModel> finalQuotationModel =
      Rxn<FinalQuotationModel>();

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null) {
      if (Get.arguments["productId"] != null) {
        productId = Get.arguments["productId"];
      }
      if (Get.arguments["imageUrl"] != null) {
        imageUrl = Get.arguments["imageUrl"];
      }
    }
    analyzeDress(imageUrl);
    _enableWakelock();
    manageScrollController();
  }

  /// Enable wakelock to prevent screen from turning off
  void _enableWakelock() async {
    try {
      if (!await WakelockPlus.enabled) {
        await WakelockPlus.enable();
        debugPrint('Wakelock enabled - screen will stay on');
      }
    } catch (e) {
      debugPrint('Error enabling wakelock: $e');
    }
  }

  /// Disable wakelock to allow screen to turn off normally
  void _disableWakelock() async {
    try {
      if (await WakelockPlus.enabled) {
        await WakelockPlus.disable();
        debugPrint('Wakelock disabled - screen can turn off normally');
      }
    } catch (e) {
      debugPrint('Error disabling wakelock: $e');
    }
  }

  void manageScrollController() async {
    scrollController.addListener(
      () {
        if (scrollController.position.maxScrollExtent ==
            scrollController.position.pixels) {
          if (nextPageStop.isTrue &&
              paginationLoading.isFalse &&
              !isNewChat.value) {
            if (scrollController.hasClients) {
              scrollController.animateTo(
                scrollController.position.maxScrollExtent + 100,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            }
            paginationLoading.value = true;
            getChatHistoryApi(isInitial: false);
          }
        }
      },
    );
  }

  Future<void> analyzeDress(String imageUrl) async {
    try {
      loader1.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.analyzeDress}", MethodType.post,
          baseUrlType: BaseUrl.chat,
          params: {
            "image_path": imageUrl,
            "product_id": productId,
          });

      if (result.isSuccess) {
        analyzeDressModel.value = AnalyzeDressModel.fromJson(result.data?.data);
        quotationId = analyzeDressModel.value.quotationId ?? "";
        getChatHistoryApi();
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      loader1.value = false;
    }
  }

  getChatHistoryApi({bool isInitial = true}) async {
    try {
      if (isInitial) {
        messages.clear(); // Use clear() instead of assigning empty list
        quotationChatHistoryModel = QuotationChatHistoryModel();
        page.value = 1;
        nextPageStop.value = true;
        loader.value = true;
      }
      if (nextPageStop.isTrue) {
        var result = await NetworkClient.instance.callApi(
          isNotNullOrEmpty(quotationChatHistoryModel.data?.timestamp)
              ? "/quotations/${quotationId}/chat-history?page=${page.value}&limit=20&timestamp=${quotationChatHistoryModel.data?.timestamp}"
              : "/quotations/${quotationId}/chat-history?page=${page.value}&limit=20",
          baseUrlType: BaseUrl.base,
          MethodType.get,
        );

        if (result.isSuccess) {
          loader.value = false;
          paginationLoading.value = false;
          if (isInitial) {
            connectSocket();
          }
          quotationChatHistoryModel =
              QuotationChatHistoryModel.fromJson(result.data?.data);
          messages.value += quotationChatHistoryModel.data?.items ?? [];
          page.value = page.value + 1;
          if (messages.isNotEmpty) {
            if (messages.length.toString() ==
                quotationChatHistoryModel.data?.total?.toString()) {
              nextPageStop.value = false;
            }
            isNewChat.value = false;
          } else {
            isNewChat.value = true;
          }
        } else {
          loader.value = false;
          paginationLoading.value = false;
          toast(result.error.toString());
        }
      }
    } catch (e) {
      loader.value = false;
      paginationLoading.value = false;
    }
  }

  void connectSocket() {
    loader.value = true;

    socket = IO.io(
      ApiConstants.chatURL,
      IO.OptionBuilder()
          .setTransports(['websocket']) // ✅ force WebSocket only
          .enableForceNew()
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .setTimeout(10000)
          .setAuth({
            'token': LocalStorageService.instance.getString(
              StorageConstants.accessToken,
            )
          })
          .build(),
    );

    // 🔥 Log all events
    socket?.onAny((event, data) {
      log("📩 Event: $event | Data: $data");
    });

    socket?.onConnect((_) {
      loader.value = false;
      socket?.emit("quotation_chat", {
        "quotation_id": quotationId,
      });

      debugPrint('✅ Socket.IO connected');
    });

    socket?.onDisconnect((_) {
      debugPrint('⚠️ Socket.IO disconnected');
      isThinking.value = false;
      loader.value = false;
    });

    socket?.onConnectError((err) {
      debugPrint('🔌 connect error: $err');
      loader.value = false;
    });

    socket?.onError((err) {
      debugPrint('❌ socket error: $err');
      isThinking.value = false;
      loader.value = false;
    });

    // server events (match your backend event names)
    socket?.on('server_message', (data) {
      final msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : data.toString();
      if (msg == "AI is thinking...") {
        thinkingMessage.value = msg.toString();
        isThinking.value = true;
      }
    });

    socket?.on('quotation_chat_response', (data) {
      isThinking.value = false;
      if (data is Map) {
        final reply = data['message'].toString();
        final rawOptions = data['options'];
        final showBodyProfileForm = data['show_body_profile_form'];
        final showBulkQuantityForm = data['show_bulk_quantity_form'];
        final finalQuotationCardDetail =
            isNotNullOrEmpty(data["quotation_card"])
                ? FinalQuotationModel.fromJson(data['quotation_card'])
                : null;

        // Insert new messages at the beginning (newest first)
        if (isNotNullOrEmpty(reply)) {
          if (messages.firstOrNull?.message != reply) {
            messages.insert(
              0,
              Message(
                sender: 'ai',
                message: reply,
              ),
            );
          }
        }
        // Safely convert to List<Option>
        buttonOptions.value = (rawOptions is List)
            ? rawOptions.map((e) => Option.fromJson(e)).toList()
            : [];

        showBodyProfile.value = showBodyProfileForm ?? false;
        showBulkQuantity.value = showBulkQuantityForm ?? false;
        finalQuotationModel.value = finalQuotationCardDetail;
      } else {
        toast(data.toString());
      }
    });

    socket?.on('error', (data) {
      final err = (data is Map && data['error'] != null)
          ? data['error'].toString()
          : data.toString();
      isThinking.value = false;
      toast('Error: $err');
    });
  }

  /// Send chat
  void sendMessage({required String message}) {
    if (message.trim().isEmpty) return;
    buttonOptions.clear();
    showBodyProfile.value = false;
    showBulkQuantity.value = false;
    finalQuotationModel.value = null;
    FocusManager.instance.primaryFocus?.unfocus();
    messages.insert(
      0,
      Message(
        sender: "user",
        message: message,
      ),
    );

    socket?.emit("quotation_chat", {
      "message": message,
      "quotation_id": quotationId,
    });

    log({
      "message": message,
      "quotation_id": quotationId,
    }.toString());
  }

  @override
  void onClose() {
    scrollController.dispose();
    typeFocusNode.dispose();
    if (socket != null) {
      socket?.close();
    }
    // Disable wakelock when controller is disposed
    _disableWakelock();
    super.onClose();
  }
}
