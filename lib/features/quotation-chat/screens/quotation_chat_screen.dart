import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/app_text_field.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/quotation-chat/controller/quotation_chat_controller.dart';
import 'package:vousvous/features/quotation-chat/models/quotation_chat_history_model.dart';
import 'package:vousvous/features/quotation-chat/widgets/chat_actions_buttons.dart';
import 'package:vousvous/features/quotation-chat/widgets/final_quotation_card.dart';
import 'package:vousvous/features/quotation-chat/widgets/quotation_ai_message_tile.dart';
import 'package:vousvous/features/quotation-chat/widgets/quotation_ai_typing_tile.dart';
import 'package:vousvous/features/quotation-chat/widgets/quotation_user_message_tile.dart';
import 'package:vousvous/features/quotation-chat/widgets/show_body_profile_widget.dart';
import 'package:vousvous/features/quotation-chat/widgets/show_bulk_quantity_widget.dart';
import 'package:vousvous/features/quotations/controller/quotations_controller.dart';

class QuotationChatScreen extends StatefulWidget {
  QuotationChatScreen({super.key});

  @override
  State<QuotationChatScreen> createState() => _QuotationChatScreenState();
}

class _QuotationChatScreenState extends State<QuotationChatScreen> {
  final QuotationChatController controller = Get.put(QuotationChatController());
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (Get.isRegistered<QuotationsController>()) {
          Get.find<QuotationsController>().getQuotationListApi();
        }
      },
      child: Obx(() {
        return Stack(
          children: [
            buildMainView(context),
            if (controller.loader.value || controller.loader1.value) AppLoader()
          ],
        );
      }),
    );
  }

  CustomScaffold buildMainView(BuildContext context) {
    return CustomScaffold(
      isTopSafeArea: false,
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4).copyWith(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                border: Border(
                    bottom: BorderSide(
                  color: Colors.white.withAlpha(30),
                )),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24)),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: SvgPicture.asset(AssetConstants.backward)),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          controller.analyzeDressModel.value.analysis?.title ??
                              "",
                          maxLines: 2,
                          style: style400S16.copyWith(
                              color: AppColors.whiteTextColor,
                              letterSpacing: 1.0,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Chat messages area with image at top (scrollable together)
            Expanded(
              child: Obx(
                () {
                  // Check if product image exists
                  final productImageUrl = controller.imageUrl.isNotEmpty
                      ? controller.imageUrl
                      : controller.analyzeDressModel.value.imageUrl ?? "";
                  final hasImage = productImageUrl.isNotEmpty;

                  return ListView.builder(
                    controller: controller.scrollController,
                    reverse: true, // Newest messages at bottom
                    physics: const AlwaysScrollableScrollPhysics()
                        .applyTo(const BouncingScrollPhysics()),
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 8,
                      bottom: 8,
                    ),
                    itemCount: controller.messages.length +
                        (controller.paginationLoading.value ? 1 : 0) +
                        (controller.isThinking.value
                            ? 1
                            : (controller.buttonOptions.isNotEmpty ? 1 : 0) +
                                (controller.showBodyProfile.value ? 1 : 0) +
                                (controller.showBulkQuantity.value ? 1 : 0) +
                                (controller.cardDetailModel.value != null
                                    ? 1
                                    : 0)) +
                        (hasImage ? 1 : 0), // Add image slot at end
                    itemBuilder: (context, index) {
                      // Calculate total extra items (before messages)
                      int extraItemsCount = 0;
                      if (controller.isThinking.value) {
                        extraItemsCount = 1;
                      } else {
                        if (controller.buttonOptions.isNotEmpty)
                          extraItemsCount++;
                        if (controller.showBodyProfile.value) extraItemsCount++;
                        if (controller.showBulkQuantity.value)
                          extraItemsCount++;
                        if (controller.cardDetailModel.value != null)
                          extraItemsCount++;
                      }

                      // Show image card at the END (appears at TOP in reversed list)
                      final imageIndex = controller.messages.length +
                          extraItemsCount +
                          (controller.paginationLoading.value ? 1 : 0);
                      if (hasImage && index == imageIndex) {
                        return _buildProductImageCard(productImageUrl);
                      }

                      // Handle pagination loading indicator
                      if (controller.paginationLoading.value &&
                          index ==
                              controller.messages.length +
                                  (controller.isThinking.value
                                      ? 1
                                      : (controller.buttonOptions.isNotEmpty
                                              ? 1
                                              : 0) +
                                          (controller.showBodyProfile.value
                                              ? 1
                                              : 0) +
                                          (controller.showBulkQuantity.value
                                              ? 1
                                              : 0))) {
                        return Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Center(
                            child: Column(
                              children: [
                                RotatingLoader(size: 20),
                                SizedBox(height: 8),
                                Text(
                                  'Loading older messages...',
                                  style: style400S12.copyWith(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // Handle typing indicator at top (newest position)
                      if (controller.isThinking.value && index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: QuotationAiTypingTile(
                              message: controller.thinkingMessage),
                        );
                      }

                      // Handle button options (only show when NOT thinking)
                      if (!controller.isThinking.value &&
                          controller.buttonOptions.isNotEmpty &&
                          index == 0) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: ChatActionsButtons(
                            options: controller.buttonOptions,
                            onOptionTap: (option) {
                              controller.sendMessage(
                                  message: option.text ?? "");
                            },
                          ),
                        );
                      }

                      // Handle body profile widget (only show when NOT thinking)
                      if (!controller.isThinking.value &&
                          controller.showBodyProfile.value &&
                          index ==
                              (controller.buttonOptions.isNotEmpty ? 1 : 0)) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: ShowBodyProfileWidget(
                            quotationChatController: controller,
                          ),
                        );
                      }
//
                      if (!controller.isThinking.value &&
                          controller.showBulkQuantity.value &&
                          index ==
                              (controller.buttonOptions.isNotEmpty ? 1 : 0)) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: ShowBulkQuantityWidget(
                            quotationChatController: controller,
                          ),
                        );
                      }

// Handle final quotation card (only show when NOT thinking)
                      if (!controller.isThinking.value &&
                          controller.cardDetailModel.value != null &&
                          index ==
                              (controller.buttonOptions.isNotEmpty ? 1 : 0) +
                                  (controller.showBodyProfile.value ? 1 : 0) +
                                  (controller.showBulkQuantity.value ? 1 : 0)) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: FinalQuotationCard(
                            quotation: controller.cardDetailModel.value ??
                                CardDetail(),
                            updatedBySupport: CardDetail(),
                          ),
                        );
                      }

                      // Calculate message index
                      int messageIndex = index;
                      if (controller.isThinking.value) {
                        messageIndex--;
                      } else {
                        if (controller.buttonOptions.isNotEmpty) messageIndex--;
                        if (controller.showBodyProfile.value) messageIndex--;
                        if (controller.showBulkQuantity.value) messageIndex--;
                        if (controller.cardDetailModel.value != null)
                          messageIndex--;
                      }

                      // Handle case where pagination loader affects indexing
                      final actualMessageIndex =
                          controller.paginationLoading.value &&
                                  messageIndex >= controller.messages.length
                              ? controller.messages.length - 1
                              : messageIndex;

                      if (actualMessageIndex < 0 ||
                          actualMessageIndex >= controller.messages.length) {
                        return SizedBox.shrink();
                      }

                      final message = controller.messages[actualMessageIndex];

                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: message.sender?.toLowerCase() == "user"
                            ? QuotationUserMessageTile(
                                message: message,
                              )
                            : QuotationAiMessageTile(
                                message: message,
                              ),
                      );
                    },
                  );
                },
              ),
            ),
            // Typing widget at bottom (inside body to prevent overlap)
            bottomTypingWidget(),
          ],
        ),
      ),
    );
  }

  Widget bottomTypingWidget() {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Column(
        mainAxisSize: MainAxisSize.min, // Only take needed space
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24), topRight: Radius.circular(24)),
            child: RepaintBoundary(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(15),
                    border: Border(
                        top: BorderSide(
                      color: Colors.white.withAlpha(30),
                    )),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: Platform.isAndroid
                              ? 8
                              : MediaQuery.viewInsetsOf(context).bottom > 0
                                  ? 8
                                  : 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            focusNode: controller.typeFocusNode,
                            controller: _textController,
                            outsideMargin: EdgeInsets.zero,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                            hint: "Start Typing...",
                            maxLines: 2,
                            minLines: 1,
                            keyboardType: TextInputType.multiline,
                            borderColor: Colors.transparent,
                            onSubmitted: (value) {
                              if (_textController.text.trim().isNotEmpty &&
                                  !controller.isThinking.value) {
                                controller.sendMessage(
                                  message: _textController.text.trim(),
                                );
                                _textController.clear();
                              }
                            },
                            suffixIcon: isKeyboardVisible
                                ? GestureDetector(
                                    onTap: () {
                                      if (_textController.text
                                              .trim()
                                              .isNotEmpty &&
                                          !controller.isThinking.value) {
                                        controller.sendMessage(
                                          message: _textController.text.trim(),
                                        );
                                        _textController.clear();
                                      }
                                    },
                                    child: SvgPicture.asset(
                                        AssetConstants.arrowUp),
                                  )
                                : GestureDetector(
                                    onTap: () {},
                                    child: SvgPicture.asset(
                                        AssetConstants.voiceCircleIcon),
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  /// Builds a WhatsApp-style product image card for the chat
  Widget _buildProductImageCard(String imageUrl) {
    if (imageUrl.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(left: 0, right: 60, bottom: 16, top: 8),
      child: Align(
        alignment: Alignment.centerLeft, // Align to left like received messages
        child: GestureDetector(
          onTap: () {
            // Open image in full screen viewer
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => Scaffold(
                  backgroundColor: Colors.black,
                  body: Stack(
                    children: [
                      Center(
                        child: InteractiveViewer(
                          child: AppNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      SafeArea(
                        child: IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon:
                              Icon(Icons.close, color: Colors.white, size: 30),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          child: Container(
            constraints: BoxConstraints(
              maxWidth:
                  MediaQuery.of(context).size.width * 0.65, // 65% width max
              minWidth: 200,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                children: [
                  // Product Image filling the container
                  AspectRatio(
                    aspectRatio: 0.75, // Portrait ratio to show full dress
                    child: AppNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover, // Cover to fill container completely
                      backgroundColor: Colors.grey.shade900,
                    ),
                  ),
                  // Subtle gradient overlay at bottom only
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withAlpha(80),
                          ],
                          stops: [0.0, 0.75, 1.0],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
