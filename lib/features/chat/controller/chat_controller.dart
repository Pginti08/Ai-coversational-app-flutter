import 'dart:developer' show log;
import 'dart:io';

import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/constants/storage_constants.dart';
import 'package:ai_fashion/core/services/local_storage_service.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/features/chat/models/chat_history_model.dart';
import 'package:ai_fashion/features/chat/models/sessions_model.dart';
import 'package:dio/dio.dart' as dio;
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
  final RxBool uploadLoader = false.obs;

  RxInt page = 1.obs;
  RxBool paginationLoading = false.obs;
  RxBool nextPageStop = true.obs;
  IO.Socket? socket;

  final RxBool isThinking = false.obs;
  final Rx<String?> thinkingMessage = Rx<String?>(null);

  String? currentSessionId;

  RxList<String> userSelectedRemixOutfits = <String>[].obs;
  RxString uploadImage = "".obs;

  // Chat messages list
  final RxList<Message> messages = <Message>[].obs;

  @override
  void onInit() {
    super.onInit();
    _enableWakelock();
    getSessionList();
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
          if (nextPageStop.isTrue &&
              paginationLoading.isFalse &&
              currentSessionId != null) {
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

  Future getSessionList() async {
    loader.value = true;

    var result = await NetworkClient.instance.callApi(
      "${ApiConstants.getSessionList}",
      MethodType.get,
      baseUrlType: BaseUrl.chat,
    );

    if (result.isSuccess) {
      loader.value = false;

      var sessionsModel = SessionsModel.fromJson(result.data?.data);
      var sessionList = sessionsModel.data?.items ?? [];

      if (sessionList.isNotEmpty) {
        currentSessionId = sessionList.first.id;
        if (isNotNullOrEmpty(currentSessionId)) {
          getChatHistoryApi();
        } else {
          connectSocket();
        }
      } else {
        connectSocket();
      }
    } else {
      loader.value = false;
      toast(result.error ?? "Failed to load data");
    }
  }

  getChatHistoryApi({bool isInitial = true}) async {
    try {
      if (isInitial) {
        messages.clear(); // Use clear() instead of assigning empty list
        page.value = 1;
        nextPageStop.value = true;
        loader.value = true;
      }
      if (nextPageStop.isTrue) {
        var result = await NetworkClient.instance.callApi(
          "/sessions/${currentSessionId}/chats?page=${page.value}&limit=100",
          baseUrlType: BaseUrl.chat,
          MethodType.get,
        );

        if (result.isSuccess) {
          loader.value = false;
          paginationLoading.value = false;
          if (isInitial) {
            connectSocket(isConnectExisting: true);
          }
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

  void connectSocket({bool isConnectExisting = false}) {
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
    socket?.onAny((event, data) {
      log("📩 Event: $event | Data: $data");
    });

    socket?.onConnect((_) {
      loader.value = false;
      debugPrint('✅ Socket.IO connected');
      if (isConnectExisting) {
        joinExistingSessionEvent(currentSessionId ?? "");
      } else {
        createNewSessionEvent();
      }
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
      final msg = (data is Map && data['msg'] != null)
          ? data['msg'].toString()
          : data.toString();
      if (msg == "AI is thinking...") {
        thinkingMessage.value = msg.toString();
        isThinking.value = true;
      }
    });

    socket?.on('session_created', (data) {
      final msg = (data is Map && data['session_id'] != null)
          ? data['session_id'].toString()
          : data.toString();
      currentSessionId = msg;
    });

    socket?.on('session_joined', (data) {
      loader.value = false;
    });

    socket?.on('generation_started', (data) {
      final msg = (data is Map && data['msg'] != null)
          ? data['msg'].toString()
          : data.toString();
      thinkingMessage.value = msg.toString();
      isThinking.value = true;
    });

    socket?.on('chat_response', (data) {
      isThinking.value = false;
      if (data is Map) {
        final reply = (data['response'] ?? data['message'])?.toString() ?? '';
        // Insert new messages at the beginning (newest first)
        messages.insert(0, Message(sender: 'ai', message: reply));
      } else {
        toast(data.toString());
      }
    });

    socket?.on('generation_complete', (data) {
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

    socket?.on('error', (data) {
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

    final refImages = isNotNullOrEmpty(userSelectedRemixOutfits)
        ? userSelectedRemixOutfits.toList() // ✅ copy instead of reference
        : [uploadImage.value];

    messages.insert(
      0,
      Message(
        sender: "user",
        message: message,
        sessionId: currentSessionId,
        refImage: refImages,
      ),
    );

    socket?.emit("user_message", {
      "prompt": message,
      "reference_filename": refImages, // ✅ send the copy too
      "uploaded_reference": [uploadImage.value],
      "session_id": currentSessionId,
    });

    log({
      "prompt": message,
      "reference_filename": refImages,
      "uploaded_reference": [uploadImage.value],
      "session_id": currentSessionId,
    }.toString());

    // Now safe to clear
    userSelectedRemixOutfits.clear();
    uploadImage.value = "";
  }

  /// Join existing session
  void joinExistingSessionEvent(String sessionId) {
    socket?.emit("join_session", {"session_id": sessionId});
  }

  void createNewSessionEvent() {
    socket?.emit("join_session", {});
  }

  void changeSession(String sessionId) async {
    toggleDrawer();
    resetAndCloseSession();
    currentSessionId = sessionId;
    getChatHistoryApi();
  }

  void newSession() {
    toggleDrawer();
    resetAndCloseSession();
    currentSessionId = null;
    connectSocket();
  }

  void resetAndCloseSession() {
    socket?.close();
    loader.value = false;
    messages.clear();
    page.value = 1;
    nextPageStop.value = true;
  }

  Future<void> imageUploadApi(File imageFile) async {
    try {
      uploadLoader.value = true;
      var result = await NetworkClient.instance
          .callApi("${ApiConstants.uploadImage}", MethodType.post,
              baseUrlType: BaseUrl.chat,
              headers: {"Content-Type": "multipart/form-data"},
              params: dio.FormData.fromMap({
                'file': dio.MultipartFile.fromFileSync(
                  imageFile.path,
                  filename: imageFile.path.split('/').last,
                  contentType: dio.DioMediaType("image", "png"),
                )
              }));

      if (result.isSuccess) {
        if (result.data != null &&
            result.data?.data != null &&
            result.data?.data["url"] != null)
          uploadImage.value = "${result.data?.data["filename"].toString()}";
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      uploadLoader.value = false;
    }
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
