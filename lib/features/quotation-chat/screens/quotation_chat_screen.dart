import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_text_field.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/quotation-chat/controller/quotation_chat_controller.dart';
import 'package:vousvous/features/quotation-chat/models/quotation_chat_history_model.dart'; // Add this import
import 'package:vousvous/features/quotation-chat/utils/date_grouping_helper.dart';
import 'package:vousvous/features/quotation-chat/widgets/chat_actions_buttons.dart';
import 'package:vousvous/features/quotation-chat/widgets/final_quotation_card.dart'; // Add this import
import 'package:vousvous/features/quotation-chat/widgets/quotation_ai_typing_tile.dart';
import 'package:vousvous/features/quotation-chat/widgets/quotation_message_tile.dart';
import 'package:vousvous/features/quotation-chat/widgets/show_body_profile_widget.dart';
import 'package:vousvous/features/quotation-chat/widgets/show_bulk_quantity_widget.dart';

class QuotationChatScreen extends StatefulWidget {
  QuotationChatScreen({super.key});

  @override
  State<QuotationChatScreen> createState() => _QuotationChatScreenState();
}

class _QuotationChatScreenState extends State<QuotationChatScreen>
    with AutomaticKeepAliveClientMixin {
  final QuotationChatController controller =
      Get.put(QuotationChatController(), tag: Get.arguments?['imageUrl']);
  final TextEditingController _textController = TextEditingController();
  final RxString inputText = ''.obs;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      return Stack(
        children: [
          buildMainView(context),
          if (controller.loader.value || controller.loader1.value) AppLoader()
        ],
      );
    });
  }

  bool get _hasBottomWidget {
    return controller.isThinking.value ||
        controller.buttonOptions.isNotEmpty ||
        controller.showBodyProfile.value ||
        controller.showBulkQuantity.value;
  }

  // Calculate total count cleanly
  int _getTotalItemCount() {
    int count = controller.messages.length;

    // Add 1 for the bottom interactive area if needed
    if (_hasBottomWidget) count++;

    // Add 1 for pagination loader if needed
    if (controller.paginationLoading.value) count++;

    return count;
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
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 4).copyWith(bottom: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(15),
                border: Border(
                    bottom: BorderSide(color: Colors.white.withAlpha(30))),
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24)),
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () => Get.back(),
                        icon: SvgPicture.asset(
                          AssetConstants.backward,
                          height: 24,
                        )),
                    Expanded(
                      child: Text(
                        controller.quotationDetailModel.value.data?.aiAnalysis
                                ?.title ??
                            "",
                        style: style400S16.copyWith(
                            color: AppColors.whiteTextColor,
                            letterSpacing: 0.5,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          _showQuotationDetailsBottomSheet(context);
                        },
                        icon: SvgPicture.asset(
                          AssetConstants.infoCircle,
                          height: 20,
                          colorFilter: ColorFilter.mode(
                              AppColors.whiteColor, BlendMode.srcIn),
                        )),
                    wSizedBox4,
                  ],
                ),
              ),
            ),
            // Chat messages area with image at top (scrollable together)
            Expanded(
              child: Obx(() {
                // Pre-calculate state to avoid logic inside the builder
                final bool showBottomWidget = _hasBottomWidget;
                final bool showPagination = controller.paginationLoading.value;
                final int messageCount = controller.messages.length;

                return ListView.separated(
                  controller: controller.scrollController,
                  reverse: true,
                  physics: const AlwaysScrollableScrollPhysics()
                      .applyTo(const BouncingScrollPhysics()),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _getTotalItemCount(),
                  separatorBuilder: (context, index) {
                    return hSizedBox10;
                  },
                  itemBuilder: (context, index) {
                    int currentIndex = index;

                    // 1. Handle Bottom Interactive Widget (Always Index 0 in Reverse)
                    if (showBottomWidget && currentIndex == 0) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: _buildBottomInteractiveWidget(),
                      );
                    }

                    // Adjust index if bottom widget is present
                    if (showBottomWidget) {
                      currentIndex--;
                    }

                    // 2. Handle Pagination Loader (At the very end, after all messages)
                    if (showPagination && currentIndex == messageCount) {
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
                                    color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // 3. Handle Messages
                    if (currentIndex >= 0 && currentIndex < messageCount) {
                      final message = controller.messages[currentIndex];
                      final previousMessage = currentIndex + 1 < messageCount
                          ? controller.messages[currentIndex + 1]
                          : null;

                      final showDate = shouldShowDateHeader(
                        message.createdAt!.toLocal(),
                        previousMessage?.createdAt!.toLocal(),
                      );

                      return Column(
                        children: [
                          if (showDate)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                getDateLabel(
                                  message.createdAt!.toLocal(),
                                ),
                                style: style400S12.copyWith(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          Padding(
                              padding: EdgeInsets.only(bottom: 16),
                              child: QuotationMessageTile(
                                  key: UniqueKey(), message: message)),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                );
              }),
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
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
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
                        crossAxisAlignment: CrossAxisAlignment.end,
                        fillColor: Colors.transparent,
                        focusNode: controller.typeFocusNode,
                        controller: _textController,
                        outsideMargin: EdgeInsets.zero,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                        hint: "Start Typing...",
                        maxLines: 4,
                        minLines: 1,
                        keyboardType: TextInputType.multiline,
                        borderColor: Colors.transparent,
                        onChanged: (value) {
                          inputText.value = value;
                        },
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
                            ? Obx(() {
                                final bool isDisabled =
                                    inputText.value.trim().isEmpty ||
                                        controller.isThinking.value;

                                return IgnorePointer(
                                  ignoring: isDisabled,
                                  child: Opacity(
                                    opacity: isDisabled ? 0.4 : 1,
                                    child: GestureDetector(
                                      onTap: () {
                                        controller.sendMessage(
                                          message: inputText.value.trim(),
                                        );
                                        _textController.clear();
                                        inputText.value = '';
                                      },
                                      child: SvgPicture.asset(
                                        AssetConstants.arrowUp,
                                      ),
                                    ),
                                  ),
                                );
                              })
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

// Helper widget to keep the Builder clean
  Widget _buildBottomInteractiveWidget() {
    if (controller.isThinking.value) {
      return QuotationAiTypingTile(message: controller.thinkingMessage);
    }

    if (controller.buttonOptions.isNotEmpty) {
      return ChatActionsButtons(
        options: controller.buttonOptions,
        onOptionTap: (option) {
          controller.sendMessage(message: option.text ?? "");
        },
      );
    }

    if (controller.showBodyProfile.value) {
      return ShowBodyProfileWidget(quotationChatController: controller);
    }

    if (controller.showBulkQuantity.value) {
      return ShowBulkQuantityWidget(quotationChatController: controller);
    }

    return SizedBox.shrink();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  void _showQuotationDetailsBottomSheet(BuildContext context) {
    // Find the latest message with card details
    final latestQuotationMessage = controller.messages.firstWhereOrNull(
      (m) => m.cardDetail != null,
    );

    if (latestQuotationMessage == null ||
        latestQuotationMessage.cardDetail == null) {
      Get.snackbar("Info", "No finalized quotation details available yet.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.black);
      return;
    }

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Color(0xFF1E1E1E), // Dark background matching app theme
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Quotation Details",
              style: style600S18.copyWith(color: AppColors.whiteTextColor),
            ),
            SizedBox(height: 16),
            FinalQuotationCard(
              quotation: latestQuotationMessage.cardDetail!,
              message: latestQuotationMessage,
              updatedBySupport:
                  latestQuotationMessage.updatedBySupport ?? UpdatedBySupport(),
              onMessageUpdate: (updatedMessage) {
                // Handle message update if needed, though controller usually handles state
                // Find the index of the message and update it in the controller
                final index = controller.messages
                    .indexWhere((m) => m.id == updatedMessage.id);
                if (index != -1) {
                  controller.messages[index] = updatedMessage;
                }
                Get.back(); // Close bottom sheet after action
              },
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
