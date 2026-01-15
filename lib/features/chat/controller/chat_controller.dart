import 'dart:async';
import 'dart:developer' show log;
import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/chat/models/brands_model.dart';
import 'package:vousvous/features/chat/models/chat_history_model.dart';
import 'package:vousvous/features/chat/models/sessions_model.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class ChatController extends GetxController {
  final RxBool isDrawerOpen = false.obs;
  final RxBool showBrandContainer = false.obs;
  final typeFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  final RxBool loader = false.obs;
  final RxBool uploadLoader = false.obs;
  final RxBool brandLoader = false.obs;

  RxInt page = 1.obs;
  RxBool paginationLoading = false.obs;
  RxBool nextPageStop = true.obs;
  ChatHistoryModel chatHistoryModel = ChatHistoryModel();
  IO.Socket? socket;

  final RxBool isThinking = false.obs;
  final Rx<String?> thinkingMessage = Rx<String?>(null);

  String? currentSessionId;

  RxList<String> userSelectedRemixOutfits = <String>[].obs;
  RxList<String> uploadImage = <String>[].obs;

  // Chat messages list
  final RxList<Message> messages = <Message>[].obs;
  final RxList<Brand> brands = <Brand>[].obs;

  final RxBool isNewChat = true.obs;

  Timer? _thinkingTimer;
  int _loadingMessageIndex = 0;
  final List<String> _engagingMessages = [
    "Analyzing your unique style preferences...",
    "Scanning global fashion trends...",
    "Curating the perfect color palette...",
    "Browsing premium fabric collections...",
    "Sketching a custom design for you...",
    "Matching accessories to complete the look...",
    "Reviewing sustainable fashion options...",
    "Checking for seasonal relevance...",
    "Adding finishing touches to the design...",
    "Simulating real-world lighting...",
    "Refining the texture details...",
    "Almost ready to unveil your look...",
  ];

  // To store the shuffled sequence for current session
  List<String> _currentCycleMessages = [];

  @override
  void onInit() {
    super.onInit();

    if (Get.arguments != null &&
        Get.arguments["userSelectedRemixOutfits"] != null) {
      userSelectedRemixOutfits.value =
          Get.arguments["userSelectedRemixOutfits"];
    }
    if (Get.arguments != null &&
        Get.arguments["isInitialRemix"] != null &&
        Get.arguments["isInitialRemix"] == true) {
      connectSocket();
    } else {
      connectSocket();
    }
    getBrandsList();
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
    scrollController.addListener(() {
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
    });
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
        print("🔥 Session List Loaded: $sessionList");
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
        chatHistoryModel = ChatHistoryModel();
        page.value = 1;
        nextPageStop.value = true;
        loader.value = true;
      }
      if (nextPageStop.isTrue) {
        var result = await NetworkClient.instance.callApi(
          "/sessions/${currentSessionId}/chats?page=${page.value}&limit=20&timestamp=${chatHistoryModel.data?.timestamp}",
          baseUrlType: BaseUrl.chat,
          MethodType.get,
        );

        print(
            "🔥 Chat History URL: /sessions/${currentSessionId}/chats?page=${page.value}&limit=20&timestamp=${chatHistoryModel.data?.timestamp} (Base: ${ApiConstants.chatURL})");
        print("🔥 Chat History Response: ${result.data?.data}");

        if (result.isSuccess) {
          loader.value = false;
          paginationLoading.value = false;
          if (isInitial) {
            connectSocket(isConnectExisting: true);
          }
          chatHistoryModel = ChatHistoryModel.fromJson(result.data?.data);
          messages.value += chatHistoryModel.data?.items ?? [];
          page.value = page.value + 1;
          if (messages.isNotEmpty) {
            if (messages.length.toString() ==
                chatHistoryModel.data?.total?.toString()) {
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

  void connectSocket({bool isConnectExisting = false}) {
    loader.value = true;

    print("🔥 Connecting Socket to: ${ApiConstants.chatURL}");
    print(
        "🔥 Token: ${LocalStorageService.instance.getString(StorageConstants.accessToken)}");

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
            ),
          })
          .build(),
    );

    // 🔥 Log all events
    socket?.onAny((event, data) {
      print("📩 CHAT_DEBUG Event: $event | Data: $data");
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
      _stopThinkingCycle();
      loader.value = false;
    });

    // server events (match your backend event names)
    socket?.on('server_message', (data) {
      final msg = (data is Map && data['msg'] != null)
          ? data['msg'].toString()
          : data.toString();
      if (msg == "AI is thinking..." || msg == "Analyzing...") {
        thinkingMessage.value = msg.toString();
        isThinking.value = true;
        _startThinkingCycle();
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
      _startThinkingCycle();
    });

    socket?.on('chat_response', (data) {
      isThinking.value = false;
      _stopThinkingCycle();
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
      _stopThinkingCycle();
      if (data is Map) {
        final String msg = (data['msg'] != null)
            ? data['msg'].toString()
            : 'Generation complete';
        final List<ImageModel> images = (data['filenames'] as List<dynamic>?)
                ?.map(
                  (e) => ImageModel(
                    filename: e.toString(),
                    text: null, // or provide default text if needed
                  ),
                )
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
      _stopThinkingCycle();
      toast('Error: $err');
    });
  }

  /// Send chat
  void sendMessage({required String message, String? referenceFilename}) {
    if (message.trim().isEmpty) return;

    FocusManager.instance.primaryFocus?.unfocus();

    final refImages = isNotNullOrEmpty(userSelectedRemixOutfits)
        ? userSelectedRemixOutfits.toList() // ✅ copy instead of reference
        : null;

    messages.insert(
      0,
      Message(
        sender: "user",
        message: message,
        sessionId: currentSessionId,
        refImage: isNotNullOrEmpty(userSelectedRemixOutfits)
            ? userSelectedRemixOutfits.toList()
            : isNotNullOrEmpty(uploadImage)
                ? uploadImage.toList()
                : null,
      ),
    );

    socket?.emit("user_message", {
      "prompt": message,
      "reference_filename":
          isNotNullOrEmpty(refImages) ? refImages : null, // ✅ send the copy too
      "uploaded_reference": isNotNullOrEmpty(uploadImage) ? uploadImage : null,
      "session_id": currentSessionId,
    });

    log(
      {
        "prompt": message,
        "reference_filename": isNotNullOrEmpty(refImages)
            ? refImages
            : null, // ✅ send the copy too
        "uploaded_reference":
            isNotNullOrEmpty(uploadImage) ? uploadImage : null,
        "session_id": currentSessionId,
      }.toString(),
    );

    // Now safe to clear
    userSelectedRemixOutfits.clear();
    uploadImage.clear();
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
    chatHistoryModel = ChatHistoryModel();
    page.value = 1;
    nextPageStop.value = true;
  }

  Future<void> uploadMultipleImages(List<File> files) async {
    // Limit: max 4 images allowed
    int available = 4 - uploadImage.length;

    if (available <= 0) {
      toast("You can upload max 4 images.");
      return;
    }

    // Only take allowed number of images
    final limitedFiles = files.take(available).toList();

    uploadLoader.value = true; // Show loader during full batch upload

    try {
      for (var file in limitedFiles) {
        await imageUploadApi(file); // Upload each file 1 by 1
      }

      if (files.length > available) {
        toast("Only $available more images allowed.");
      }
    } finally {
      uploadLoader.value = false;
    }
  }

  Future<void> imageUploadApi(File imageFile) async {
    try {
      uploadLoader.value = true;
      var result = await NetworkClient.instance.callApi(
        "${ApiConstants.uploadImage}",
        MethodType.post,
        baseUrlType: BaseUrl.chat,
        headers: {"Content-Type": "multipart/form-data"},
        params: dio.FormData.fromMap({
          'file': dio.MultipartFile.fromFileSync(
            imageFile.path,
            filename: imageFile.path.split('/').last,
            contentType: dio.DioMediaType("image", "png"),
          ),
        }),
      );

      if (result.isSuccess) {
        if (result.data != null &&
            result.data?.data != null &&
            result.data?.data["url"] != null)
          uploadImage.add("${result.data?.data["filename"].toString()}");
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      uploadLoader.value = false;
    }
  }

  Future getBrandsList() async {
    brandLoader.value = true;

    var result = await NetworkClient.instance.callApi(
      "${ApiConstants.getBrandList}?page=1&limit=100",
      MethodType.get,
      baseUrlType: BaseUrl.base,
    );

    if (result.isSuccess) {
      brandLoader.value = false;
      var brandsModel = BrandsModel.fromJson(result.data?.data);
      brands.value = brandsModel.data?.brands ?? [];
    } else {
      brandLoader.value = false;
      toast(result.error ?? "Failed to load data");
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
    _stopThinkingCycle();
    super.onClose();
  }

  void _startThinkingCycle() {
    _stopThinkingCycle(); // reset if already running
    _loadingMessageIndex = 0;

    // Prepare shuffled cycle
    // 1. Get all messages except the last one ("Almost ready...")
    var cycleOptions =
        _engagingMessages.sublist(0, _engagingMessages.length - 1);
    // 2. Shuffle them to ensure randomness
    cycleOptions.shuffle();
    // 3. Add the last message at the end
    cycleOptions.add(_engagingMessages.last);

    _currentCycleMessages = cycleOptions;

    // Increased delay to 6 seconds.
    _thinkingTimer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (_loadingMessageIndex < _currentCycleMessages.length) {
        thinkingMessage.value = _currentCycleMessages[_loadingMessageIndex];

        // Only increment if we haven't reached the last message
        // If we reached the last message, we stay there (don't loop back)
        if (_loadingMessageIndex < _currentCycleMessages.length - 1) {
          _loadingMessageIndex++;
        }
      }
    });
  }

  void _stopThinkingCycle() {
    _thinkingTimer?.cancel();
    _thinkingTimer = null;
  }
}
