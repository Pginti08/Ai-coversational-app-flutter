import 'dart:io';
import 'dart:ui';

import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/ai_message_tile.dart';
import 'package:ai_fashion/core/widgets/ai_typing_tile.dart';
import 'package:ai_fashion/core/widgets/app_loader.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/app_text_field.dart';
import 'package:ai_fashion/core/widgets/blur_bottom_sheet.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/core/widgets/stacked_card_widget.dart';
import 'package:ai_fashion/core/widgets/user_message_tile.dart';
import 'package:ai_fashion/features/chat/controller/chat_controller.dart';
import 'package:ai_fashion/features/chat/screens/widgets/past_conversation.dart';
import 'package:ai_fashion/features/chat/screens/widgets/upload_image_type_bottom_sheet.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController controller = Get.put(ChatController());
  final TextEditingController _textController = TextEditingController();

  // Add this variable to control brand container visibility

  // List of outfit categories for horizontal scroll
  final List<String> startCreatingFromTheseList = [
    "Front-slit dress for weekend party",
    "Flowy maxi dress for beach brunch",
    "Bright bodycon dress for sundowner",
    "Backless satin dress for date night",
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final drawerWidth = screenWidth * 0.85;

    return Obx(() {
      final isOpen = controller.isDrawerOpen.value;

      return Stack(
        children: [
          ClipRRect(
            child: Stack(
              children: [
                // LAYER 1: The drawer with proper clipping
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  left: isOpen
                      ? 0
                      : -drawerWidth, // Move drawer off-screen when closed
                  top: 0,
                  bottom: 0,
                  width: drawerWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.blackColor, // Solid opaque background
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    child: ColoredBox(
                        // Prevent transparency leak
                        color: AppColors.blackColor,
                        child: PastConversation(
                          controller: controller,
                        )),
                  ),
                ),

                // LAYER 2: The main content view with full background
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOutCubic,
                  left: isOpen ? drawerWidth : 0,
                  right: isOpen ? -drawerWidth : 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    color: AppColors.blackColor, // Ensure solid background
                    child: ClipRect(
                      child: Stack(
                        children: [
                          // The actual content of your main screen
                          buildMainView(context),

                          // This scrim layer covers the main content when the drawer is open.
                          if (isOpen)
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  onTap: controller.toggleDrawer,
                                  child: Container(
                                      color: Colors.black.withAlpha(150)),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (controller.loader.value) AppLoader()
        ],
      );
    });
  }

  CustomScaffold buildMainView(BuildContext context) {
    return CustomScaffold(
        isEffect2: true,
        body: GestureDetector(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            // Hide brand container when tapping outside
            controller.showBrandContainer.value = false;
          },
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                      onPressed: () {
                        controller.toggleDrawer();
                      },
                      icon: SvgPicture.asset(AssetConstants.menu)),
                  IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: SvgPicture.asset(AssetConstants.closeIcon))
                ],
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
                        (controller.isThinking.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      // Handle pagination loading indicator at bottom (oldest messages)
                      if (controller.paginationLoading.value &&
                          index ==
                              controller.messages.length +
                                  (controller.isThinking.value ? 1 : 0)) {
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
                          child:
                              AiTypingTile(message: controller.thinkingMessage),
                        );
                      }

                      // Calculate message index
                      final messageIndex =
                          controller.isThinking.value ? index - 1 : index;

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
                            ? UserMessageTile(
                                message: message,
                              )
                            : AiMessageTile(message: message),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                height: controller.showBrandContainer.value
                    ? 200.h
                    : controller.userSelectedRemixOutfits.isNotEmpty ||
                            isNotNullOrEmpty(controller.uploadImage.value)
                        ? 160.h
                        : 100.h,
              )
            ],
          ),
        ),
        bottomNavigationBar: Obx(() => Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: Platform.isAndroid
                      ? 8
                      : MediaQuery.viewInsetsOf(context).bottom > 0
                          ? 8
                          : 0),
              child: SafeArea(
                child: controller.showBrandContainer.value
                    ? buildBrandContainer()
                    : bottomTypingWidget(),
              ),
            )));
  }

  // New method for brand container
  Widget buildBrandContainer() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: CommonContainer(
        height: 300.h,
        width: double.infinity,
        enableBlur: true,
        borderColor: AppColors.greyBorderColor,
        borderRadius: 24,
        backgroundColor: AppColors.blackColor.withAlpha(180),
        child: Column(
          children: [
            // Header with search and close
            Padding(
              padding: const EdgeInsets.all(14).copyWith(right: 0),
              child: Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      borderColor: Colors.transparent,
                      fillColor: AppColors.grey2Color,
                      hint: 'Search Brands',
                      outsideMargin:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      contentPadding: EdgeInsets.zero,
                      borderRadius: 100,
                      readOnly: true,
                      hintStyle: style400S14.copyWith(
                        letterSpacing: 0.28,
                        color: Color(0xFF999999),
                      ),
                      prefixIcon: SvgPicture.asset(
                        AssetConstants.search,
                      ),
                      onTap: () {
                        Get.toNamed(Routes.brandSearch);
                      },
                    ),
                  ),
                  SizedBox(
                    width: 100.w,
                  ),
                  IconButton(
                    onPressed: () {
                      controller.showBrandContainer.value = false;
                    },
                    icon: SvgPicture.asset(AssetConstants.closeIcon),
                  ),
                ],
              ),
            ),

            // Brand grid
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: 20,
                itemBuilder: (context, index) {
                  return CommonContainer(
                      onTap: () {
                        // Handle brand selection
                        if (!controller.isThinking.value &&
                            !controller.uploadLoader.value) {
                          controller.sendMessage(message: "Dresses by Zara");
                          controller.showBrandContainer.value = false;
                        }
                      },
                      backgroundColor: AppColors.grey2Color,
                      borderRadius: 10,
                      child: AppNetworkImage(
                        imageUrl:
                            "https://i.pinimg.com/474x/af/84/6e/af846e8b9c2f4ecec25e6a13e0faa07e.jpg",
                        fit: BoxFit.cover,
                      ));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget bottomTypingWidget() {
    return KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
      return Obx(() => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.messages.isEmpty) ...[
                startCreatingFromTheseTile(),
                hSizedBox18,
              ],
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: RepaintBoundary(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        border: GradientBoxBorder(
                          width: 1,
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: controller
                                        .userSelectedRemixOutfits.isNotEmpty ||
                                    isNotNullOrEmpty(
                                        controller.uploadImage.value)
                                ? AppColors.colorGradient
                                : AppColors.glassBorderGradient,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Obx(
                            () => (controller
                                    .userSelectedRemixOutfits.isNotEmpty)
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                    vertical: 8.0)
                                                .copyWith(right: 10),
                                            child: CardDeckWidget(
                                              maxCards: 4,
                                              items: controller
                                                  .userSelectedRemixOutfits
                                                  .map((e) => e)
                                                  .toList()
                                                  .obs,
                                              itemBuilder: (imageUrl) =>
                                                  ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: AppNetworkImage(
                                                  imageUrl: "$imageUrl",
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  fit: BoxFit.cover,
                                                  width: 50,
                                                  height: 50,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: CommonContainer(
                                              isCircle: true,
                                              width: 24,
                                              height: 24,
                                              backgroundColor:
                                                  Color(0xFF797877),
                                              onTap: () {
                                                controller
                                                    .userSelectedRemixOutfits
                                                    .clear();
                                                controller.uploadImage.value =
                                                    "";
                                              },
                                              child: SvgPicture.asset(
                                                AssetConstants.closeCircleIcon,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  )
                                : isNotNullOrEmpty(controller.uploadImage.value)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Stack(
                                            clipBehavior: Clip.none,
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                        vertical: 8.0)
                                                    .copyWith(right: 10),
                                                child: CardDeckWidget(
                                                  maxCards: 1,
                                                  items: [
                                                    controller.uploadImage.value
                                                  ].obs,
                                                  itemBuilder: (imageUrl) =>
                                                      ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                    child: AppNetworkImage(
                                                      imageUrl: "$imageUrl",
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              4),
                                                      fit: BoxFit.cover,
                                                      width: 50,
                                                      height: 50,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Positioned(
                                                right: 0,
                                                top: 0,
                                                child: CommonContainer(
                                                  isCircle: true,
                                                  width: 24,
                                                  height: 24,
                                                  backgroundColor:
                                                      Color(0xFF797877),
                                                  onTap: () {
                                                    controller
                                                        .userSelectedRemixOutfits
                                                        .clear();
                                                    controller
                                                        .uploadImage.value = "";
                                                  },
                                                  child: SvgPicture.asset(
                                                    AssetConstants
                                                        .closeCircleIcon,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      )
                                    : controller.uploadLoader.value
                                        ? Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: RotatingLoader(
                                              size: 30,
                                            ),
                                          )
                                        : SizedBox.shrink(),
                          ),
                          AppTextField(
                            focusNode: controller.typeFocusNode,
                            controller: _textController,
                            outsideMargin: EdgeInsets.zero,
                            contentPadding: EdgeInsets.symmetric(vertical: 6),
                            hint: "Start Creating...",
                            borderColor: Colors.transparent,
                            onSubmitted: (value) {
                              if (value.trim().isNotEmpty &&
                                  !controller.isThinking.value &&
                                  !controller.uploadLoader.value) {
                                controller.sendMessage(
                                  message: value.trim(),
                                );
                                _textController.clear();
                                controller.userSelectedRemixOutfits.clear();
                                controller.uploadImage.value = "";
                              }
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CommonContainer(
                                    height: 32,
                                    width: 32,
                                    backgroundColor:
                                        AppColors.greyTextColor.withAlpha(100),
                                    enableBlur: true,
                                    isCircle: true,
                                    onTap: () async {
                                      final File? pickedImage =
                                          await BlurBottomSheet().show<File?>(
                                        height:
                                            MediaQuery.sizeOf(context).height *
                                                0.2,
                                        context: context,
                                        borderColor:
                                            AppColors.whiteColor.withAlpha(40),
                                        backgroundColor:
                                            AppColors.scaffoldColor,
                                        barrierColor:
                                            AppColors.blackColor.withAlpha(50),
                                        blurStrength: 30,
                                        isCloseButton: true,
                                        child:
                                            const UploadImageTypeBottomSheet(),
                                      );
                                      if (pickedImage != null) {
                                        controller.imageUploadApi(pickedImage);
                                      }
                                    },
                                    padding: EdgeInsets.all(4),
                                    child: Icon(Icons.add),
                                  ),
                                  wSizedBox12,
                                  CommonContainer(
                                    height: 32,
                                    backgroundColor:
                                        AppColors.greyTextColor.withAlpha(100),
                                    enableBlur: true,
                                    borderRadius: 100,
                                    onTap: () {
                                      // Toggle brand container visibility with haptic feedback
                                      controller.showBrandContainer.value =
                                          !controller.showBrandContainer.value;
                                    },
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    child: Center(
                                      child: AnimatedDefaultTextStyle(
                                        duration: Duration(milliseconds: 200),
                                        style: style700S12.copyWith(
                                            letterSpacing: 0.96),
                                        child: Text("BRANDS"),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              isKeyboardVisible
                                  ? IconButton(
                                      onPressed: () {
                                        if (_textController.text
                                                .trim()
                                                .isNotEmpty &&
                                            !controller.isThinking.value &&
                                            !controller.uploadLoader.value) {
                                          controller.sendMessage(
                                            message:
                                                _textController.text.trim(),
                                          );
                                          _textController.clear();
                                          controller.userSelectedRemixOutfits
                                              .clear();
                                          controller.uploadImage.value = "";
                                        }
                                      },
                                      icon: SvgPicture.asset(
                                          AssetConstants.arrowUp),
                                    )
                                  : IconButton(
                                      onPressed: () {},
                                      icon: SvgPicture.asset(
                                          AssetConstants.voiceCircleIcon),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ));
    });
  }

  Column startCreatingFromTheseTile() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(AssetConstants.sparkle),
            wSizedBox8,
            Text(
              "Start Creating from these.".toUpperCase(),
              style: style700S12.copyWith(letterSpacing: 0.96),
            ),
          ],
        ),
        hSizedBox12,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              startCreatingFromTheseList.length,
              (index) => Padding(
                padding: EdgeInsets.only(right: 12),
                child: CommonContainer(
                    width: 160.w,
                    enableBlur: true,
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    borderRadius: 20,
                    borderGradientColors: AppColors.glassBorderGradient,
                    onTap: () {
                      controller.sendMessage(
                          message: startCreatingFromTheseList[index]);
                    },
                    child: Text(
                      startCreatingFromTheseList[index],
                      maxLines: 2,
                      style: style400S16.copyWith(
                        color: Color(0XFF999999),
                      ),
                    )),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
