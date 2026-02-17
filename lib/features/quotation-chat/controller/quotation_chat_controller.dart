import 'dart:developer' show log;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/product-detail/models/check_quotation_exists_model.dart';
import 'package:vousvous/features/quotation-chat/models/quotation_chat_history_model.dart'
    hide Data;
import 'package:vousvous/features/quotation-chat/models/quotation_detail_model.dart'
    hide Data;
import 'package:vousvous/features/quotation-chat/widgets/chat_actions_buttons.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class QuotationChatController extends GetxController {
  String imageUrl = "";
  String productId = "";
  String status = "";
  final RxBool isDrawerOpen = false.obs;
  final typeFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  final RxBool loader = false.obs;
  final RxBool loader1 = false.obs;
  final Rx<CheckQuotationExistsModel> quotationDetailModel =
      CheckQuotationExistsModel().obs;

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
  final RxList<Item> messages = <Item>[].obs;

  //chat actions - ONLY show these when NOT part of a message
  final RxList<Option> buttonOptions = <Option>[].obs;
  final RxBool showBodyProfile = false.obs;
  final RxBool showBulkQuantity = false.obs;

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
      if (Get.arguments["quotationId"] != null) {
        quotationId = Get.arguments["quotationId"];
      }
      if (Get.arguments["status"] != null) {
        status = Get.arguments["status"];
      }
    }
    if (isNullOrEmpty(quotationId)) {
      checkQuotationStatus();
    } else {
      getQuotationDetails();
    }
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

  Future<void> checkQuotationStatus() async {
    try {
      loader1.value = true;
      var result = await NetworkClient.instance.callApi(
        isNotNullOrEmpty(productId)
            ? "${ApiConstants.checkQuotationExists}?productId=${productId}"
            : "${ApiConstants.checkQuotationExists}?image=${imageUrl}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        var checkExistsQuotationModel =
            CheckQuotationExistsModel.fromJson(result.data?.data);
        quotationId = checkExistsQuotationModel.data?.quotationId ?? "";
        getQuotationDetails();
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      loader1.value = false;
    }
  }

  Future<void> getQuotationDetails() async {
    try {
      loader1.value = true;

      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.quotations}/${quotationId}",
        MethodType.get,
        baseUrlType: BaseUrl.base,
      );

      if (result.isSuccess) {
        var quotationDetail = QuotationDetailModel.fromJson(result.data?.data);
        quotationDetailModel.value = CheckQuotationExistsModel(
            data: Data(
                quotationId: quotationId,
                exists: true,
                aiAnalysis: AiAnalysis(
                    color: quotationDetail.data?.color,
                    description: quotationDetail.data?.description,
                    material: quotationDetail.data?.material,
                    title: quotationDetail.data?.title,
                    type: quotationDetail.data?.type)));
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
        messages.clear();
        quotationChatHistoryModel = QuotationChatHistoryModel();
        page.value = 1;
        nextPageStop.value = true;
        loader.value = true;
      }
      if (nextPageStop.isTrue) {
        var result = await NetworkClient.instance.callApi(
          isNotNullOrEmpty(quotationChatHistoryModel.data?.timestampDate)
              ? "/quotations/${quotationId}/chat-history?page=${page.value}&limit=20&timestamp=${quotationChatHistoryModel.data?.timestampDate}"
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
                (quotationChatHistoryModel.data?.total ?? 0).toString()) {
              nextPageStop.value = false;
              // Add image message at the end
              // if (isNotNullOrEmpty(imageUrl)) {
              //   messages.add(Message(
              //     sender: 'ai',
              //     message: imageUrl,
              //     messageType: 'image',
              //   ));
              // }
            }
            isNewChat.value = false;
          } else {
            isNewChat.value = true;
            // Add image message at the end (oldest position) if it's initial load
            // if (isNotNullOrEmpty(imageUrl)) {
            //   messages.add(Message(
            //     sender: 'ai',
            //     message: imageUrl,
            //     messageType: 'image',
            //   ));
            // }
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
      toast(e.toString());
    }
  }

  void connectSocket() {
    loader.value = true;
    socket = IO.io(
      ApiConstants.baseURL,
      IO.OptionBuilder()
          .setTransports(['websocket'])
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

    socket?.onAny((event, data) {
      log("📩 Event: $event | Data: $data");
    });

    socket?.onConnect((_) {
      socket?.emit("join_room", {
        quotationId,
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

    socket?.on('server_message', (data) {
      final msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : data.toString();
      if (msg == "AI is thinking...") {
        thinkingMessage.value = msg.toString();
        isThinking.value = true;
      }
    });

    socket?.on('joined_room', (data) {
      loader.value = false;
      debugPrint('✅ Joined Room ${data["roomId"]}');
    });
    socket?.on('receive_message', (data) {
      // Add receiver message
      messages.insert(
        0,
        Item(
          messageType: data['messageType'],
          message: data["message"],
          imageUrl: data["imageUrl"],
          createdAt: DateTime.tryParse(data['createdAt'].toString()),
        ),
      );
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

    // Clear UI actions but NOT messages
    buttonOptions.clear();
    showBodyProfile.value = false;
    showBulkQuantity.value = false;

    FocusManager.instance.primaryFocus?.unfocus();

    // Add user message
    messages.insert(
      0,
      Item(
          sender: "user",
          message: message,
          messageType: 'text',
          createdAt: DateTime.now().toUtc()),
    );

    socket?.emit("send_message", {
      "message": message,
      "messageType": "text",
      "roomId": quotationId,
    });

    log({
      "message": message,
      "messageType": "text",
      "roomId": quotationId,
    }.toString());
  }

  @override
  void onClose() {
    scrollController.dispose();
    typeFocusNode.dispose();
    if (socket != null) {
      socket?.close();
    }
    _disableWakelock();
    super.onClose();
  }
}
