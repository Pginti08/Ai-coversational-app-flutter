import 'package:ai_fashion/features/chat/models/chat_message.dart';
import 'package:ai_fashion/features/home/models/product_list_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final RxBool isDrawerOpen = false.obs;
  final RxBool showBrandContainer = false.obs;
  final typeFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();

  // Chat messages list
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  // Loading state for typing indicator
  final RxBool isLoading = false.obs;
  RxList<Product> userSelectedRemixOutfits = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  void toggleDrawer() {
    isDrawerOpen.value = !isDrawerOpen.value;
  }

  // Send message and get dummy response
  void sendMessage({required String message, List<Product>? outfits}) {
    FocusManager.instance.primaryFocus?.unfocus();
    if ((outfits ?? []).isEmpty) {
      // Add user message
      messages.add(ChatMessage.user(message: message));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      // Show typing indicator
      isLoading.value = true;

      // Simulate AI response after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        isLoading.value = false;

        // Add AI response
        messages.add(ChatMessage.ai(
            message:
                "Here are some curated dressed for you. Tap on the deck to view the dress.",
            outfits: [
              Product(
                image:
                    "https://framerusercontent.com/images/ioTL88ZpHCWXDdmKwFbhBBMJfA.png",
                title: "The Midnight Monochrome Street Set",
              ),
              Product(
                image:
                    "https://framerusercontent.com/images/EDnff5CDaVTXO7iJhG2jmUWgJos.png",
                title: "The Sandstone Explorer Co-Ord",
              ),
              Product(
                image:
                    "https://framerusercontent.com/images/497wrI6QPtcqc9q1y7a7kdGc.png",
                title: "The Urban Ash Layered Look",
              ),
              Product(
                image:
                    "https://framerusercontent.com/images/uwRHxl9xBPMQcwC7g6f5k6z5o.png",
                title: "The Crimson Bolt Street Set",
              ),
              Product(
                image:
                    "https://framerusercontent.com/images/0cz3vf6fEsEb13ulylzz3lTR4.png",
                title: "The Ivory Mocha Luxe Dress",
              ),
            ]));
        Future.delayed(Duration(milliseconds: 300), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      });
    } else {
      messages
          .add(ChatMessage.user(message: message, outfits: [...outfits ?? []]));
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );

      // Show typing indicator
      isLoading.value = true;

      // Simulate AI response after 3 seconds
      Future.delayed(Duration(seconds: 3), () {
        isLoading.value = false;

        // Add AI response
        messages.add(ChatMessage.ai(
            message:
                "Here is your curated dress. Tap on the dress to view the details and order it for you.",
            outfits: [
              Product(
                image:
                    "https://framerusercontent.com/images/497wrI6QPtcqc9q1y7a7kdGc.png",
                title: "The Urban Ash Layered Look",
              ),
            ]));
        Future.delayed(Duration(milliseconds: 300), () {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      });
    }
  }
}
