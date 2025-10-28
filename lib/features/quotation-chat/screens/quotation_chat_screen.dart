import 'dart:io';
import 'dart:ui';

import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/widgets/app_loader.dart';
import 'package:ai_fashion/core/widgets/app_text_field.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/quotation-chat/controller/quotation_chat_controller.dart';
import 'package:ai_fashion/features/quotation-chat/widgets/chat_actions_buttons.dart';
import 'package:ai_fashion/features/quotation-chat/widgets/final_quotation_card.dart';
import 'package:ai_fashion/features/quotation-chat/widgets/quotation_ai_message_tile.dart';
import 'package:ai_fashion/features/quotation-chat/widgets/quotation_ai_typing_tile.dart';
import 'package:ai_fashion/features/quotation-chat/widgets/quotation_user_message_tile.dart';
import 'package:ai_fashion/features/quotation-chat/widgets/show_body_profile_widget.dart';
import 'package:ai_fashion/features/quotation-chat/widgets/show_bulk_quantity_widget.dart';
import 'package:ai_fashion/features/quotations/controller/quotations_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

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
                      child: Text(
                        controller.analyzeDressModel.value.analysis?.title ??
                            "",
                        maxLines: 2,
                        style: style400S16.copyWith(
                            color: AppColors.whiteTextColor,
                            letterSpacing: 0.32,
                            overflow: TextOverflow.ellipsis),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // Chat messages area
            Expanded(
              child: Obx(
                () => ListView.builder(
                  controller: controller.scrollController,
                  reverse: true, // Newest messages at top, oldest at bottom
                  physics: const AlwaysScrollableScrollPhysics()
                      .applyTo(const BouncingScrollPhysics()),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.messages.length +
                      (controller.paginationLoading.value ? 1 : 0) +
                      (controller.isThinking.value
                          ? 1
                          : (controller.buttonOptions.isNotEmpty ? 1 : 0) +
                              (controller.showBodyProfile.value ? 1 : 0) +
                              (controller.showBulkQuantity.value ? 1 : 0) +
                              (controller.finalQuotationModel.value != null
                                  ? 1
                                  : 0)),
                  itemBuilder: (context, index) {
                    // Handle pagination loading indicator at bottom (oldest messages)
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
                            controller.sendMessage(message: option.text ?? "");
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
                        controller.finalQuotationModel.value != null &&
                        index ==
                            (controller.buttonOptions.isNotEmpty ? 1 : 0) +
                                (controller.showBodyProfile.value ? 1 : 0) +
                                (controller.showBulkQuantity.value ? 1 : 0)) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: FinalQuotationCard(
                          quotation: controller.finalQuotationModel.value!,
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
                      if (controller.finalQuotationModel.value != null)
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
                ),
              ),
            ),
            SizedBox(
              height: 60.h,
            )
          ],
        ),
      ),
      bottomNavigationBar: bottomTypingWidget(),
    );
  }

  Widget bottomTypingWidget() {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Column(
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
}
