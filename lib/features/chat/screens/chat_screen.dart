import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/haptic_service.dart';
import 'package:vousvous/core/services/performance_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/app_text_field.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/core/widgets/stacked_card_widget.dart';
import 'package:vousvous/features/chat/controller/chat_controller.dart';
import 'package:vousvous/features/chat/screens/widgets/past_conversation.dart';
import 'package:vousvous/features/chat/screens/widgets/upload_image_type_bottom_sheet.dart';
import 'package:vousvous/features/chat/widgets/ai_message_tile.dart';
import 'package:vousvous/features/chat/widgets/ai_typing_tile.dart';
import 'package:vousvous/features/chat/widgets/user_message_tile.dart';
import 'package:vousvous/routes/app_pages.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatController controller = Get.put(ChatController());
  final TextEditingController _textController = TextEditingController();
  final RxString inputText = ''.obs;

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

      return GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swipe right to open drawer (positive velocity)
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 300) {
            if (!isOpen) controller.toggleDrawer();
          }
          // Swipe left to close drawer (negative velocity)
          if (details.primaryVelocity != null &&
              details.primaryVelocity! < -300) {
            if (isOpen) controller.toggleDrawer();
          }
        },
        child: Stack(
          children: [
            // LAYER 1: Main content (Chat Screen) - stays in place
            buildMainView(context),

            // LAYER 2: Dark overlay when drawer is open
            if (isOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: controller.toggleDrawer,
                  child: AnimatedOpacity(
                    duration: PerformanceService.instance.animationDuration,
                    opacity: isOpen ? 1.0 : 0.0,
                    child: BackdropFilter(
                      filter:
                          PerformanceService.instance.getScaledBlurFilter(8),
                      child: Container(
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),

            // LAYER 3: Drawer sliding from left (overlay)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              left: isOpen ? 0 : -drawerWidth,
              top: 0,
              bottom: 0,
              width: drawerWidth,
              child: Material(
                color: AppColors.blackColor,
                elevation: 16,
                shadowColor: Colors.black54,
                child: PastConversation(controller: controller),
              ),
            ),

            if (controller.loader.value) AppLoader()
          ],
        ),
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
                                chatController: controller,
                              )
                            : AiMessageTile(
                                message: message,
                                chatController: controller,
                              ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(
                height: controller.showBrandContainer.value
                    ? 200.h
                    : controller.userSelectedRemixOutfits.isNotEmpty ||
                            isNotNullOrEmpty(controller.uploadImage)
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
              child: Obx(() => controller.brandLoader.value
                  ? Center(child: RotatingLoader())
                  : GridView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1,
                      ),
                      itemCount: controller.brands.length,
                      itemBuilder: (context, index) {
                        return CommonContainer(
                            onTap: () {
                              // Handle brand selection
                              if (!controller.isThinking.value &&
                                  !controller.uploadLoader.value) {
                                controller.sendMessage(
                                    message:
                                        "Dresses by ${controller.brands[index].name}");
                                controller.showBrandContainer.value = false;
                              }
                            },
                            backgroundColor: AppColors.grey2Color,
                            borderRadius: 10,
                            child: AppNetworkImage(
                              imageUrl: controller.brands[index].logo ?? "",
                              fit: BoxFit.cover,
                            ));
                      },
                    )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityDropdown() {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      offset: const Offset(0, -145),
      color: const Color(0xFF1E1E1E),
      elevation: 20,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.white.withAlpha(30)),
      ),
      onSelected: (value) {
        controller.selectedQuality.value = value;

        HapticService.light();
      },
      itemBuilder: (context) => ['SD', 'HD', 'HD+'].map((q) {
        final isSelected = controller.selectedQuality.value == q;
        return PopupMenuItem<String>(
          value: q,
          child: Row(
            children: [
              Text(
                q,
                style: style700S12.copyWith(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
              if (isSelected) ...[
                const Spacer(),
                const Icon(Icons.check_circle_rounded,
                    size: 14, color: Color(0xFF68C3E7)),
              ]
            ],
          ),
        );
      }).toList(),
      child: Obx(() {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: AppColors.whiteColor.withAlpha(50),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.whiteColor.withAlpha(60),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF68C3E7).withAlpha(50),
                blurRadius: 10,
                spreadRadius: -1,
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: AppColors.colorGradient,
                ).createShader(bounds),
                child: Text(
                  controller.selectedQuality.value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: Colors.white,
              ),
            ],
          ),
        );
      }),
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
                    filter: PerformanceService.instance.getScaledBlurFilter(10),
                    child: Container(
                      width: double.infinity,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(15),
                        border: GradientBoxBorder(
                          width: 1,
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: controller
                                        .userSelectedRemixOutfits.isNotEmpty ||
                                    isNotNullOrEmpty(controller.uploadImage)
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
                            () => Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (controller
                                    .userSelectedRemixOutfits.isNotEmpty)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
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
                                                  const Color(0xFF797877),
                                              onTap: () {
                                                controller
                                                    .userSelectedRemixOutfits
                                                    .clear();
                                              },
                                              child: SvgPicture.asset(
                                                AssetConstants.closeCircleIcon,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                if (controller.uploadLoader.value)
                                  Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: RotatingLoader(
                                      size: 30,
                                    ),
                                  ),
                                if (isNotNullOrEmpty(controller.uploadImage))
                                  SizedBox(
                                    height: 70,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: controller.uploadImage.length,
                                      itemBuilder: (context, index) {
                                        final imageUrl =
                                            controller.uploadImage[index];

                                        return Stack(
                                          clipBehavior: Clip.none,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                          vertical: 8.0)
                                                      .copyWith(right: 10),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                                child: AppNetworkImage(
                                                  imageUrl: imageUrl,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  fit: BoxFit.cover,
                                                  width: 50,
                                                  height: 50,
                                                ),
                                              ),
                                            ),

                                            /// ❌ Delete Button
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: CommonContainer(
                                                isCircle: true,
                                                width: 24,
                                                height: 24,
                                                backgroundColor:
                                                    const Color(0xFF797877),
                                                onTap: () {
                                                  controller.uploadImage
                                                      .removeAt(index);
                                                  controller.update();
                                                },
                                                child: SvgPicture.asset(
                                                  AssetConstants
                                                      .closeCircleIcon,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
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
                                  final List<File>? pickedImage =
                                      await BlurBottomSheet().show<List<File>?>(
                                    height:
                                        MediaQuery.sizeOf(context).height * 0.2,
                                    context: context,
                                    borderColor:
                                        AppColors.whiteColor.withAlpha(40),
                                    backgroundColor:
                                        AppColors.scaffoldColor.withAlpha(200),
                                    barrierColor:
                                        AppColors.blackColor.withAlpha(50),
                                    blurStrength: 10,
                                    isCloseButton: true,
                                    child: UploadImageTypeBottomSheet(
                                      uploadedImages: controller.uploadImage,
                                    ),
                                  );
                                  if (pickedImage != null) {
                                    if (controller.uploadImage.length < 4) {
                                      controller
                                          .uploadMultipleImages(pickedImage);
                                    } else {
                                      toast("Maximum 4 images allowed.");
                                    }
                                  }
                                },
                                padding: EdgeInsets.all(4),
                                child: Icon(Icons.add),
                              ),
                              wSizedBox10,
                              Expanded(
                                child: AppTextField(
                                  focusNode: controller.typeFocusNode,
                                  controller: _textController,
                                  outsideMargin: EdgeInsets.zero,
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 6),
                                  hint: "Start Creating...",
                                  maxLines: 2,
                                  minLines: 1,
                                  keyboardType: TextInputType.multiline,
                                  borderColor: Colors.transparent,
                                  onChanged: (value) {
                                    inputText.value = value;
                                  },
                                  onSubmitted: (value) {
                                    if (value.trim().isNotEmpty &&
                                        !controller.isThinking.value &&
                                        !controller.uploadLoader.value) {
                                      controller.sendMessage(
                                        message: value.trim(),
                                      );
                                      _textController.clear();
                                      controller.userSelectedRemixOutfits
                                          .clear();
                                      controller.uploadImage.clear();
                                    }
                                  },
                                  suffixIcon: _buildQualityDropdown(),
                                ),
                              ),
                              wSizedBox10,
                              if (isKeyboardVisible)
                                Obx(() => IgnorePointer(
                                      ignoring:
                                          inputText.value.trim().isEmpty ||
                                              controller.isThinking.value ||
                                              controller.uploadLoader.value,
                                      child: Opacity(
                                        opacity: inputText.value
                                                    .trim()
                                                    .isEmpty ||
                                                controller.isThinking.value ||
                                                controller.uploadLoader.value
                                            ? 0.4
                                            : 1,
                                        child: GestureDetector(
                                          onTap: () {
                                            controller.sendMessage(
                                              message:
                                                  _textController.text.trim(),
                                            );
                                            _textController.clear();
                                            controller.userSelectedRemixOutfits
                                                .clear();
                                            controller.uploadImage.clear();
                                          },
                                          child: SvgPicture.asset(
                                            AssetConstants.arrowUp,
                                          ),
                                        ),
                                      ),
                                    ))
                            ],
                          ),
                          // Row(
                          //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //   children: [
                          //     Row(
                          //       children: [
                          //         // CommonContainer(
                          //         //   height: 32,
                          //         //   width: 32,
                          //         //   backgroundColor:
                          //         //       AppColors.greyTextColor.withAlpha(100),
                          //         //   enableBlur: true,
                          //         //   isCircle: true,
                          //         //   onTap: () async {
                          //         //     final List<File>? pickedImage =
                          //         //         await BlurBottomSheet()
                          //         //             .show<List<File>?>(
                          //         //       height:
                          //         //           MediaQuery.sizeOf(context).height *
                          //         //               0.2,
                          //         //       context: context,
                          //         //       borderColor:
                          //         //           AppColors.whiteColor.withAlpha(40),
                          //         //       backgroundColor:
                          //         //           AppColors.scaffoldColor,
                          //         //       barrierColor:
                          //         //           AppColors.blackColor.withAlpha(50),
                          //         //       blurStrength: 10,
                          //         //       isCloseButton: true,
                          //         //       child: UploadImageTypeBottomSheet(
                          //         //         uploadedImages:
                          //         //             controller.uploadImage,
                          //         //       ),
                          //         //     );
                          //         //     if (pickedImage != null) {
                          //         //       if (controller.uploadImage.length < 4) {
                          //         //         controller.uploadMultipleImages(
                          //         //             pickedImage);
                          //         //       } else {
                          //         //         toast("Maximum 4 images allowed.");
                          //         //       }
                          //         //     }
                          //         //   },
                          //         //   padding: EdgeInsets.all(4),
                          //         //   child: Icon(Icons.add),
                          //         // ),
                          //         // wSizedBox12,
                          //         // CommonContainer(
                          //         //   height: 32,
                          //         //   backgroundColor:
                          //         //       AppColors.greyTextColor.withAlpha(100),
                          //         //   enableBlur: true,
                          //         //   borderRadius: 100,
                          //         //   onTap: () {
                          //         //     // Toggle brand container visibility with haptic feedback
                          //         //     controller.showBrandContainer.value =
                          //         //         !controller.showBrandContainer.value;
                          //         //   },
                          //         //   padding:
                          //         //       EdgeInsets.symmetric(horizontal: 10),
                          //         //   child: Center(
                          //         //     child: AnimatedDefaultTextStyle(
                          //         //       duration: Duration(milliseconds: 200),
                          //         //       style: style700S12.copyWith(
                          //         //           letterSpacing: 0.96),
                          //         //       child: Text("BRANDS"),
                          //         //     ),
                          //         //   ),
                          //         // ),
                          //       ],
                          //     ),
                          //     // if (isKeyboardVisible)
                          //     //   GestureDetector(
                          //     //     onTap: () {
                          //     //       if (_textController.text
                          //     //               .trim()
                          //     //               .isNotEmpty &&
                          //     //           !controller.isThinking.value &&
                          //     //           !controller.uploadLoader.value) {
                          //     //         controller.sendMessage(
                          //     //           message: _textController.text.trim(),
                          //     //         );
                          //     //         _textController.clear();
                          //     //         controller.userSelectedRemixOutfits
                          //     //             .clear();
                          //     //         controller.uploadImage.clear();
                          //     //       }
                          //     //     },
                          //     //     child:
                          //     //         SvgPicture.asset(AssetConstants.arrowUp),
                          //     //   )
                          //   ],
                          // ),
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
                      if (!controller.isThinking.value &&
                          !controller.uploadLoader.value) {
                        controller.sendMessage(
                            message: startCreatingFromTheseList[index]);
                      }
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
