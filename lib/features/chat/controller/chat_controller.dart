import 'dart:developer' show log;

import 'package:ai_fashion/core/constants/storage_constants.dart';
import 'package:ai_fashion/core/services/local_storage_service.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/chat/models/chat_history_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:wakelock_plus/wakelock_plus.dart';

class ChatController extends GetxController {
  final RxBool isDrawerOpen = false.obs;
  final RxBool showBrandContainer = false.obs;
  final typeFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  final RxBool loader = false.obs;
  RxInt page = 1.obs;
  RxBool paginationLoading = false.obs;
  RxBool nextPageStop = true.obs;
  late IO.Socket socket;

  final RxBool isThinking = false.obs;
  final Rx<String?> thinkingMessage = Rx<String?>(null);

  String? currentSessionId;

  RxList<String> userSelectedRemixOutfits = <String>[].obs;
  // Chat messages list
  final RxList<Message> messages = <Message>[].obs;

  @override
  void onInit() {
    super.onInit();
    connectSocket();
    _enableWakelock();
    manageScrollController();
  }

  void toggleDrawer() {
    FocusManager.instance.primaryFocus?.unfocus();
    isDrawerOpen.value = !isDrawerOpen.value;
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
          if (nextPageStop.isTrue && paginationLoading.isFalse) {
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

  getChatHistoryApi(
      {bool isInitial = true, bool isChangeSession = false}) async {
    try {
      if (isInitial) {
        messages.clear(); // Use clear() instead of assigning empty list
        page.value = 1;
        nextPageStop.value = true;
        loader.value = true;
      }

      if (nextPageStop.isTrue) {
        var result = await NetworkClient.instance.callApi(
          "/sessions/${currentSessionId}/chats?page=${page.value}&limit=20",
          baseUrlType: BaseUrl.chat,
          MethodType.get,
        );

        if (result.isSuccess) {
          loader.value = false;
          paginationLoading.value = false;

          if (isChangeSession) {
            joinSession(currentSessionId ?? "");
          }

          loader.value = false;
          paginationLoading.value = false;

          var chatHistoryModel = ChatHistoryModel.fromJson(result.data?.data);
          messages.value += chatHistoryModel.data?.items ?? [];
          page.value = page.value + 1;
          if (messages.isNotEmpty) {
            if (messages.length.toString() ==
                chatHistoryModel.data?.total?.toString()) {
              nextPageStop.value = false;
            }
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
      "http://34.233.54.141:8000", // ✅ full URL
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
    socket.onAny((event, data) {
      log("📩 Event: $event | Data: $data");
    });

    socket.onConnect((_) {
      loader.value = false;
      debugPrint('✅ Socket.IO connected');
    });

    socket.onDisconnect((_) {
      debugPrint('⚠️ Socket.IO disconnected');
      isThinking.value = false;
      loader.value = false;
    });

    socket.onConnectError((err) {
      debugPrint('🔌 connect error: $err');
      loader.value = false;
    });

    socket.onError((err) {
      debugPrint('❌ socket error: $err');
      isThinking.value = false;
      loader.value = false;
    });

    // server events (match your backend event names)
    socket.on('server_message', (data) {
      final msg = (data is Map && data['msg'] != null)
          ? data['msg'].toString()
          : data.toString();
      if (msg == "AI is thinking...") {
        thinkingMessage.value = msg.toString();
        isThinking.value = true;
      }
    });

    socket.on('session_created', (data) {
      final msg = (data is Map && data['session_id'] != null)
          ? data['session_id'].toString()
          : data.toString();
      currentSessionId = msg;
    });

    socket.on('session_joined', (data) {
      loader.value = false;
    });

    socket.on('generation_started', (data) {
      final msg = (data is Map && data['msg'] != null)
          ? data['msg'].toString()
          : data.toString();
      thinkingMessage.value = msg.toString();
      isThinking.value = true;
    });

    socket.on('chat_response', (data) {
      isThinking.value = false;
      if (data is Map) {
        final reply = (data['response'] ?? data['message'])?.toString() ?? '';
        // Insert new messages at the beginning (newest first)
        messages.insert(0, Message(sender: 'ai', message: reply));
      } else {
        toast(data.toString());
      }
    });

    socket.on('generation_complete', (data) {
      isThinking.value = false;
      if (data is Map) {
        final String msg = (data['msg'] != null)
            ? data['msg'].toString()
            : 'Generation complete';
        final List<ImageModel> images = (data['filenames'] as List<dynamic>?)
                ?.map((e) => ImageModel(
                      filename: e.toString(),
                      text: null, // or provide default text if needed
                    ))
                .toList() ??
            [];

        messages.insert(0, Message(sender: 'ai', message: msg, images: images));
      } else {
        toast(data.toString());
      }
    });

    socket.on('error', (data) {
      final err = (data is Map && data['error'] != null)
          ? data['error'].toString()
          : data.toString();
      isThinking.value = false;
      toast('Error: $err');
    });
  }

  /// Send chat
  void sendMessage({required String message, String? referenceFilename}) {
    if (message.trim().isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();
    messages.insert(
        0,
        Message(
            sender: "user",
            message: message,
            refImage: userSelectedRemixOutfits.firstOrNull));
    isThinking.value = true;

    socket.emit("user_message", {
      "prompt": message,
      "reference_filename": userSelectedRemixOutfits.isEmpty
          ? null
          : userSelectedRemixOutfits.first, // optional
    });
    userSelectedRemixOutfits.clear();
  }

  /// Join existing session
  void joinSession(String sessionId) {
    loader.value = true;
    socket.emit("join_session", {"session_id": sessionId});
  }

  void changeSession(String sessionId) {
    toggleDrawer();
    currentSessionId = sessionId;
    getChatHistoryApi(isChangeSession: true);
  }

  void newSession() {
    toggleDrawer();
    currentSessionId = null;
    messages.clear(); // Clear messages for new session
    page.value = 1;
    nextPageStop.value = true;
  }

  @override
  void onClose() {
    scrollController.dispose();
    typeFocusNode.dispose();
    socket.close();
    // Disable wakelock when controller is disposed
    _disableWakelock();
    super.onClose();
  }
}
