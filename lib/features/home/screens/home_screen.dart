import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/haptic_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/core/widgets/shimmer_utils.dart';
import 'package:vousvous/features/home/controller/home_controller.dart';
import 'package:vousvous/features/home/screens/start_creating_drag_bottom.dart';
import 'package:vousvous/features/home/screens/user_menu.dart';
import 'package:vousvous/features/home/widgets/product_outfit_card.dart';
import 'package:vousvous/features/home/widgets/top_progress_bar.dart';
import 'package:vousvous/routes/app_pages.dart';

enum ThumbSelection { skip, shuffle, favorite, none }

// Enum to manage the guide steps - UPDATED with thumb gestures
enum GuideStep {
  none,
  dragDown,
  thumbLeft, // NEW
  thumbRight, // NEW
  swipeRight,
  swipeLeft,
  openDrawer,
  done,
}

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final HomeController controller = Get.put(HomeController());

  late AnimationController _animationController;
  late Animation<double> _overlayAnimation;

  double _pullDownHeight = 0;
  double _thumbPosition = 0;
  ThumbSelection _selectedOption = ThumbSelection.none;
  bool _isPullingDown = false;

  // GlobalKey to find the drawer icon position for the guide
  final GlobalKey _drawerIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _overlayAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    _thumbPosition = details.globalPosition.dx;
    _selectedOption = _getSelectionFromPosition(_thumbPosition, screenWidth);

    setState(() {
      _isPullingDown = true;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    // Only allow downward dragging from top
    if (details.delta.dy > 0) {
      setState(() {
        _pullDownHeight += details.delta.dy * 0.8;
        _pullDownHeight = _pullDownHeight.clamp(0.0, 200.0);
      });

      // Check if user performed the correct guide step
      if (_pullDownHeight > 160) {
        if (controller.currentGuideStep.value == GuideStep.dragDown) {
          controller.currentGuideStep.value = GuideStep.thumbLeft;
        }
      }
    }

    // Update thumb horizontal position
    _thumbPosition = details.globalPosition.dx;

    // Update selection based on current thumb position
    final newSelection = _getSelectionFromPosition(_thumbPosition, screenWidth);
    if (newSelection != _selectedOption) {
      // --- USER GUIDE LOGIC: Track thumb movements ---
      setState(() {
        _selectedOption = newSelection;
      });

      // Check if user moved thumb left during thumbLeft guide step
      if (controller.currentGuideStep.value == GuideStep.thumbLeft) {
        if (newSelection == ThumbSelection.skip) {
          // User moved thumb to the left successfully
          controller.currentGuideStep.value = GuideStep.thumbRight;
        }
      }

      // --- END USER GUIDE LOGIC ---

      HapticService.medium();
    }
  }

  ThumbSelection _getSelectionFromPosition(
    double position,
    double screenWidth,
  ) {
    final leftBound = screenWidth * 0.33;
    final rightBound = screenWidth * 0.67;

    if (position < leftBound) {
      return ThumbSelection.skip;
    } else if (position > rightBound) {
      return ThumbSelection.favorite;
    } else {
      return ThumbSelection.shuffle;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    // Trigger action if pulled down enough
    if (_pullDownHeight > 160) {
      _navigateBasedOnSelection();
    }

    // Reset and animate back
    _overlayAnimation = Tween<double>(
      begin: _pullDownHeight / 200,
      end: 0,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward().then((_) {
      setState(() {
        _pullDownHeight = 0;
        _thumbPosition = 0;
        _selectedOption = ThumbSelection.none;
        _isPullingDown = false;
      });
      _animationController.reset();
    });
  }

  void _navigateBasedOnSelection() {
    switch (_selectedOption) {
      case ThumbSelection.skip:
        Get.toNamed(Routes.skipped);
        if (controller.currentGuideStep.value == GuideStep.thumbRight) {
          controller.currentGuideStep.value = GuideStep.dragDown;
        }

        break;
      case ThumbSelection.shuffle:
        controller.getSuggestedProducts(isShuffle: true);
        if (controller.currentGuideStep.value == GuideStep.thumbLeft ||
            controller.currentGuideStep.value == GuideStep.thumbRight) {
          controller.currentGuideStep.value = GuideStep.dragDown;
        }
        break;
      case ThumbSelection.favorite:
        Get.toNamed(Routes.liked);
        if (controller.currentGuideStep.value == GuideStep.thumbRight) {
          controller.currentGuideStep.value = GuideStep.swipeRight;
        }
        break;
      case ThumbSelection.none:
        break;
    }
  }

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
                  left: isOpen ? 0 : -drawerWidth,
                  top: 0,
                  bottom: 0,
                  width: drawerWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.blackColor,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(0),
                        bottomRight: Radius.circular(0),
                      ),
                    ),
                    child: ColoredBox(
                      color: AppColors.blackColor,
                      child: UserMenu(controller: controller),
                    ),
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
                    color: AppColors.blackColor,
                    child: ClipRect(
                      child: Stack(
                        children: [
                          buildMainView(),
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
                                  child: RepaintBoundary(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaX: 8,
                                        sigmaY: 8,
                                      ),
                                      child: Container(
                                        color: Colors.black.withAlpha(100),
                                      ),
                                    ),
                                  ),
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
          if (controller.isLoading.value) AppLoader(),

          // --- USER GUIDE OVERLAY ---
          // TODO: Guide temporarily disabled
          // _buildGuideOverlay(),
          // --- END USER GUIDE OVERLAY ---
        ],
      );
    });
  }

  Stack buildMainView() {
    return Stack(
      children: [
        // Main content with body sliding effect
        GestureDetector(
          onVerticalDragStart: _handleDragStart,
          onVerticalDragUpdate: _handleDragUpdate,
          onVerticalDragEnd: _handleDragEnd,
          child: CustomScaffold(
            isBottomSafeArea: false,
            body: AnimatedBuilder(
              animation: _overlayAnimation,
              builder: (context, child) {
                final progress = (_pullDownHeight / 200).clamp(0.0, 1.0);
                final currentProgress = _animationController.isAnimating
                    ? _overlayAnimation.value
                    : progress;

                final slideOffset = currentProgress * 80;

                return Transform.translate(
                  offset: Offset(0, slideOffset),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: topProgressImageNameWidget(),
                      ),
                      Expanded(
                        child: Obx(
                          () => Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ).copyWith(bottom: 150),
                            child: controller.isLoading.value
                                ? SizedBox.shrink()
                                : controller.suggestedProductsList.length ==
                                            0 ||
                                        ((controller.currentCardIndex.value) >=
                                            controller
                                                .suggestedProductsList.length)
                                    ? Center(
                                        child: controller.isPaginating.value
                                            ? shimmer(
                                                child: Text(
                                                  "Finding more products you might love...",
                                                  style: style600S20.copyWith(
                                                    letterSpacing: 0.42,
                                                    color: AppColors
                                                        .whiteTextColor,
                                                    height: 1.1,
                                                  ),
                                                ),
                                              )
                                            : Builder(
                                                builder: (context) {
                                                  print(
                                                      "🚫 SHOWING 'No More Outfits Available'");
                                                  print(
                                                      "   - Products list length: ${controller.suggestedProductsList.length}");
                                                  print(
                                                      "   - Current card index: ${controller.currentCardIndex.value}");
                                                  print(
                                                      "   - Remaining in queue: ${controller.remainingProductsInQueue.value}");
                                                  print(
                                                      "   - Has more products: ${controller.hasMoreProducts}");
                                                  print(
                                                      "   - Current page: ${controller.currentPage}");
                                                  return Text(
                                                    "No More Outfits Available",
                                                    style: style600S20.copyWith(
                                                      letterSpacing: 0.42,
                                                      color: AppColors
                                                          .whiteTextColor,
                                                      height: 1.1,
                                                    ),
                                                  );
                                                },
                                              ),
                                      )
                                    : CardSwiper(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 10,
                                        ),
                                        numberOfCardsDisplayed: controller
                                                    .suggestedProductsList
                                                    .length <
                                                4
                                            ? controller
                                                .suggestedProductsList.length
                                            : 4,
                                        scale: 0.97,
                                        backCardOffset: Offset(0, 25),
                                        allowedSwipeDirection:
                                            AllowedSwipeDirection.only(
                                          left: true,
                                          right: true,
                                        ),
                                        cardsCount: controller
                                            .suggestedProductsList.length,
                                        isLoop: false,
                                        cardBuilder: (
                                          context,
                                          index,
                                          percentThresholdX,
                                          percentThresholdY,
                                        ) {
                                          return Obx(
                                            () => ProductOutfitCard(
                                              product: controller
                                                  .suggestedProductsList[index],
                                              isFirst: (controller
                                                          .currentCardIndex
                                                          .value ==
                                                      index)
                                                  .obs,
                                              swipeProgress: double.tryParse(
                                                    percentThresholdX
                                                        .toString(),
                                                  ) ??
                                                  0,
                                              onTap: () {
                                                Get.toNamed(
                                                  Routes.productDetail,
                                                  arguments: {
                                                    "productDetail": controller
                                                            .suggestedProductsList[
                                                        index],
                                                  },
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        initialIndex:
                                            controller.currentCardIndex.value,
                                        onSwipe: (
                                          previousIndex,
                                          currentIndex,
                                          direction,
                                        ) {
                                          final outfitList =
                                              controller.suggestedProductsList;

                                          if (previousIndex < 0 ||
                                              previousIndex >=
                                                  outfitList.length) {
                                            return true;
                                          }

                                          print("👆 SWIPE DETECTED:");
                                          print(
                                              "   - Direction: ${direction == CardSwiperDirection.right ? 'RIGHT (LIKED)' : 'LEFT (SKIPPED)'}");
                                          print(
                                              "   - Previous Index: $previousIndex");
                                          print(
                                              "   - Current Index: $currentIndex");

                                          if (direction ==
                                              CardSwiperDirection.right) {
                                            if (controller
                                                    .currentGuideStep.value ==
                                                GuideStep.swipeRight) {
                                              controller.currentGuideStep
                                                  .value = GuideStep.swipeLeft;
                                            }

                                            controller.likedProduct(
                                              outfitList[previousIndex].id ??
                                                  "",
                                            );
                                          } else if (direction ==
                                              CardSwiperDirection.left) {
                                            if (controller
                                                    .currentGuideStep.value ==
                                                GuideStep.swipeLeft) {
                                              controller.currentGuideStep
                                                  .value = GuideStep.openDrawer;
                                            }

                                            controller.skipProduct(
                                              outfitList[previousIndex].id ??
                                                  "",
                                            );
                                          }
                                          controller
                                              .remainingProductsInQueue.value--;

                                          print(
                                              "   - Remaining in queue after swipe: ${controller.remainingProductsInQueue.value}");
                                          print(
                                              "   - Total products in list: ${controller.suggestedProductsList.length}");

                                          if (controller
                                                      .remainingProductsInQueue
                                                      .value <
                                                  5 &&
                                              !controller.isLoading.value &&
                                              !controller.isPaginating.value) {
                                            print(
                                                "🔄 Triggering LOAD MORE (remaining < 5)");
                                            controller.getSuggestedProducts(
                                              isLoadMore: true,
                                            );
                                          }

                                          if (currentIndex != null) {
                                            controller.currentCardIndex.value =
                                                currentIndex;
                                          } else if (currentIndex == null &&
                                              controller
                                                      .currentCardIndex.value ==
                                                  outfitList.length - 1) {
                                            controller.currentCardIndex.value++;
                                          }

                                          print(
                                              "   - New card index: ${controller.currentCardIndex.value}");
                                          return true;
                                        },
                                      ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            bottomNavigationBar: AnimatedBuilder(
              animation: _overlayAnimation,
              builder: (context, child) {
                final progress = (_pullDownHeight / 200).clamp(0.0, 1.0);
                final currentProgress = _animationController.isAnimating
                    ? _overlayAnimation.value
                    : progress;

                final slideOffset = currentProgress * 40;

                return Transform.translate(
                  offset: Offset(0, slideOffset * 0.5),
                  child: StartCreatingDragBottom(),
                );
              },
            ),
          ),
        ),

        // Pull-down overlay
        if (_isPullingDown && _pullDownHeight > 0) _buildPullDownOverlay(),
      ],
    );
  }

  Widget _buildPullDownOverlay() {
    final progress = (_pullDownHeight / 200).clamp(0.0, 1.0);

    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _overlayAnimation,
        builder: (context, child) {
          final currentProgress = _animationController.isAnimating
              ? _overlayAnimation.value
              : progress;

          return Stack(
            children: [
              // Blur background
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: currentProgress * 10,
                  sigmaY: currentProgress * 10,
                ),
                child: Container(
                  color: Colors.black.withOpacity(currentProgress * 0.2),
                ),
              ),

              // Options panel at top
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Transform.translate(
                  offset: Offset(0, (1 - currentProgress) * -150),
                  child: Container(
                    height: 300,
                    child: SafeArea(
                      bottom: false,
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              SizedBox(height: 30),

                              // Three options
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildOptionButton(
                                    "Skipped",
                                    AssetConstants.previous,
                                    ThumbSelection.skip,
                                    currentProgress,
                                  ),
                                  _buildOptionButton(
                                    "Shuffle",
                                    AssetConstants.shuffle,
                                    ThumbSelection.shuffle,
                                    currentProgress,
                                  ),
                                  _buildOptionButton(
                                    "Liked",
                                    AssetConstants.heart,
                                    ThumbSelection.favorite,
                                    currentProgress,
                                  ),
                                ],
                              ),

                              SizedBox(height: 20),
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
        },
      ),
    );
  }

  Widget _buildOptionButton(
    String label,
    String icon,
    ThumbSelection option,
    double progress,
  ) {
    final isSelected = _selectedOption == option;
    final scale = isSelected ? 1.1 : 1.0;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      transform: Matrix4.identity()..scale(scale),
      child: Container(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: isSelected
                      ? Colors.white.withAlpha(30)
                      : Colors.transparent,
                ),
                gradient: isSelected
                    ? RadialGradient(
                        colors: [
                          Colors.black.withAlpha(100),
                          Colors.black.withAlpha(50),
                          Colors.black.withAlpha(30),
                          Colors.black.withAlpha(15),
                          Colors.black.withAlpha(10),
                          Colors.white.withAlpha(10),
                          Colors.white.withAlpha(20),
                        ],
                      )
                    : null,
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Color(0x28A3A3A3),
                          blurRadius: 10,
                          offset: Offset(0, 0),
                          spreadRadius: 3,
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    icon,
                    color:
                        isSelected ? Colors.white : Colors.white.withAlpha(150),
                  ),
                ],
              ),
            ),
            SizedBox(height: 4),
            if (isSelected)
              Text(
                label.toUpperCase(),
                style: style700S12.copyWith(fontSize: 10, letterSpacing: 0.80),
              ),
          ],
        ),
      ),
    );
  }

  Widget topProgressImageNameWidget() {
    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Obx(
          () => TopProgressBar(
            value: controller.currentCardIndex.value,
            maxValue: controller.suggestedProductsList.length,
            height: 50,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4.5),
          child: Row(
            children: [
              GestureDetector(
                key: _drawerIconKey,
                onTap: () {
                  // TODO: Guide temporarily disabled
                  // // Disable tap if guide is active and not on openDrawer step
                  // if (controller.currentGuideStep.value != GuideStep.none &&
                  //     controller.currentGuideStep.value != GuideStep.done &&
                  //     controller.currentGuideStep.value !=
                  //         GuideStep.openDrawer) {
                  //   // User must complete current guide step first
                  //   return;
                  // }

                  // if (controller.currentGuideStep.value ==
                  //     GuideStep.openDrawer) {
                  //   controller.currentGuideStep.value = GuideStep.done;
                  //   controller.markGuideSeen();
                  // }
                  controller.toggleDrawer();
                },
                child: Obx(
                  () => AppNetworkImage(
                    width: 43,
                    height: 43,
                    shape: BoxShape.circle,
                    imageUrl: controller.userImage.value,
                    fit: BoxFit.cover,
                    errorWidget: Container(
                      width: 43,
                      height: 43,
                      color: AppColors.grey2Color.withAlpha(150),
                      padding: EdgeInsets.all(8),
                      alignment: Alignment.center,
                      child: SvgPicture.asset(
                        AssetConstants.user,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
              wSizedBox12,
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "HELLO",
                      style: style700S12.copyWith(
                        fontSize: 10,
                        letterSpacing: 0.80,
                        color: AppColors.whiteColor,
                      ),
                    ),
                    Obx(
                      () => Text(
                        controller.userName.value
                                .split(" ")
                                .first
                                .capitalizeFirst ??
                            "",
                        style: style600S20.copyWith(
                          letterSpacing: 0.42,
                          color: AppColors.whiteTextColor,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- USER GUIDE WIDGETS ---
  Widget _buildGuideOverlay() {
    return Obx(() {
      final step = controller.currentGuideStep.value;
      if (step == GuideStep.none || step == GuideStep.done) {
        return const SizedBox.shrink();
      }

      final guideInfo = _getGuideInfoForStep(step);

      return Positioned.fill(
        child: IgnorePointer(
          ignoring: true,
          child: Material(
            color: Colors.transparent,
            child: ClipPath(
              clipper: HoleClipper(guideInfo.highlightRect),
              child: Container(
                color: Colors.black.withOpacity(0.75),
                child: Stack(children: [guideInfo.guideWidget]),
              ),
            ),
          ),
        ),
      );
    });
  }

  _GuideInfo _getGuideInfoForStep(GuideStep step) {
    final screenSize = MediaQuery.sizeOf(context);
    final topPadding = MediaQuery.paddingOf(context).top;

    switch (step) {
      case GuideStep.dragDown:
        return _GuideInfo(
          highlightRect: Rect.zero,
          guideWidget: Positioned(
            top: topPadding + 90,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(
                  Icons.arrow_downward_rounded,
                  color: Colors.white,
                  size: 40,
                ),
                Text(
                  "Drag down from the top\nto see quick options",
                  textAlign: TextAlign.center,
                  style: style600S16.copyWith(color: Colors.white, height: 1.3),
                ),
              ],
            ),
          ),
        );

      // NEW: Thumb Left Guide Step
      case GuideStep.thumbLeft:
        return _GuideInfo(
          highlightRect: Rect.zero,
          guideWidget: Positioned(
            top: topPadding + 160,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.touch_app_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  "Move your thumb LEFT\nto select 'Skipped'",
                  textAlign: TextAlign.center,
                  style: style600S16.copyWith(color: Colors.white, height: 1.3),
                ),
              ],
            ),
          ),
        );

      // NEW: Thumb Right Guide Step
      case GuideStep.thumbRight:
        return _GuideInfo(
          highlightRect: Rect.zero,
          guideWidget: Positioned(
            top: topPadding + 160,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  "Now move your thumb RIGHT\nto select 'Liked'",
                  textAlign: TextAlign.center,
                  style: style600S16.copyWith(color: Colors.white, height: 1.3),
                ),
              ],
            ),
          ),
        );

      case GuideStep.swipeRight:
        return _GuideInfo(
          highlightRect: Rect.fromCenter(
            center: Offset(screenSize.width / 2, (screenSize.height / 2) - 50),
            width: screenSize.width * 0.85,
            height: screenSize.height * 0.55,
          ),
          guideWidget: Positioned(
            bottom: screenSize.height * 0.2,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 40,
                ),
                Text(
                  "Swipe right to LIKE",
                  textAlign: TextAlign.center,
                  style: style600S16.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        );

      case GuideStep.swipeLeft:
        return _GuideInfo(
          highlightRect: Rect.fromCenter(
            center: Offset(screenSize.width / 2, (screenSize.height / 2) - 50),
            width: screenSize.width * 0.85,
            height: screenSize.height * 0.55,
          ),
          guideWidget: Positioned(
            bottom: screenSize.height * 0.2,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Icon(Icons.arrow_back_rounded, color: Colors.white, size: 40),
                Text(
                  "Swipe left to SKIP",
                  textAlign: TextAlign.center,
                  style: style600S16.copyWith(color: Colors.white),
                ),
              ],
            ),
          ),
        );

      case GuideStep.openDrawer:
        Rect drawerRect = Rect.fromCircle(
          center: Offset(32, topPadding + 27),
          radius: 100,
        );

        final renderBox =
            _drawerIconKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          final size = renderBox.size;

          final center = Offset(
            position.dx + size.width / 3,
            position.dy + size.height / 2,
          );

          drawerRect = Rect.fromCircle(
            center: center,
            radius: size.width / 2 + 10,
          );
        }

        return _GuideInfo(
          highlightRect: drawerRect,
          guideWidget: Positioned(
            top: drawerRect.bottom + 10,
            left: drawerRect.left + 10,
            child: Text(
              "Tap here to open\nyour menu",
              style: style600S16.copyWith(color: Colors.white, height: 1.3),
            ),
          ),
        );

      default:
        return _GuideInfo(
          highlightRect: Rect.zero,
          guideWidget: const SizedBox.shrink(),
        );
    }
  }
}

// --- HELPER CLASSES FOR GUIDE ---

/// Helper class to pass guide info
class _GuideInfo {
  final Rect highlightRect;
  final Widget guideWidget;
  _GuideInfo({required this.highlightRect, required this.guideWidget});
}

/// CustomClipper to "punch a hole" in the overlay
class HoleClipper extends CustomClipper<Path> {
  final Rect holeRect;
  HoleClipper(this.holeRect);

  @override
  Path getClip(Size size) {
    // Create a path for the entire screen
    final fullScreenPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create a path for the hole, as a rounded rectangle
    final holePath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(holeRect, const Radius.circular(16)),
      );

    // Subtract the hole from the full screen
    return Path.combine(PathOperation.difference, fullScreenPath, holePath);
  }

  @override
  bool shouldReclip(HoleClipper oldClipper) {
    return oldClipper.holeRect != holeRect;
  }
}
