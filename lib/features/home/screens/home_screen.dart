import 'dart:ui';

import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/services/haptic_service.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_loader.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/core/widgets/shimmer_utils.dart';
import 'package:ai_fashion/features/home/controller/home_controller.dart';
import 'package:ai_fashion/features/home/screens/start_creating_drag_bottom.dart';
import 'package:ai_fashion/features/home/screens/user_menu.dart';
import 'package:ai_fashion/features/home/widgets/product_outfit_card.dart';
import 'package:ai_fashion/features/home/widgets/top_progress_bar.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

enum ThumbSelection { skip, shuffle, favorite, none }

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
    }

    // Update thumb horizontal position
    _thumbPosition = details.globalPosition.dx;

    // Update selection based on current thumb position
    final newSelection = _getSelectionFromPosition(_thumbPosition, screenWidth);
    if (newSelection != _selectedOption) {
      setState(() {
        _selectedOption = newSelection;
      });
      HapticService.medium();
    }
  }

  ThumbSelection _getSelectionFromPosition(
      double position, double screenWidth) {
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
    _overlayAnimation =
        Tween<double>(begin: _pullDownHeight / 200, end: 0).animate(
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
        break;
      case ThumbSelection.shuffle:
        controller.getSuggestedProducts();
        break;
      case ThumbSelection.favorite:
        Get.toNamed(Routes.liked);
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
                        child: UserMenu(
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
                          buildMainView(),

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
                                  child: RepaintBoundary(
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                          sigmaX: 8, sigmaY: 8),
                                      child: Container(
                                          color: Colors.black.withAlpha(100)),
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
          if (controller.isLoading.value) AppLoader()
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

                // Calculate slide down offset for body only
                final slideOffset = currentProgress *
                    80; // Adjust multiplier for slide distance

                return Transform.translate(
                  offset: Offset(0, slideOffset),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: topProgressImageNameWidget(),
                      ),
                      Expanded(
                          child: Obx(() => Padding(
                                padding: EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12)
                                    .copyWith(bottom: 150),
                                child: controller.isLoading.value
                                    ? SizedBox.shrink()
                                    : controller.suggestedProductsList.length ==
                                                0 ||
                                            ((controller
                                                    .currentCardIndex.value) >=
                                                controller.suggestedProductsList
                                                    .length)
                                        ? Center(
                                            child: controller.isPaginating.value
                                                ? shimmer(
                                                    child: Text(
                                                      "Finding more products you might love...",
                                                      style: style600S20.copyWith(
                                                          letterSpacing: 0.42,
                                                          color: AppColors
                                                              .whiteTextColor,
                                                          height: 1.1),
                                                    ),
                                                  )
                                                : Text(
                                                    "No More Outfits Available",
                                                    style: style600S20.copyWith(
                                                        letterSpacing: 0.42,
                                                        color: AppColors
                                                            .whiteTextColor,
                                                        height: 1.1),
                                                  ),
                                          )
                                        : CardSwiper(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10),
                                            numberOfCardsDisplayed: 4,
                                            scale: 0.97,
                                            backCardOffset: Offset(0, 25),
                                            allowedSwipeDirection:
                                                AllowedSwipeDirection.only(
                                                    left: true, right: true),
                                            cardsCount: controller
                                                .suggestedProductsList.length,
                                            isLoop: false,
                                            cardBuilder: (context,
                                                index,
                                                percentThresholdX,
                                                percentThresholdY) {
                                              return Obx(() => GestureDetector(
                                                    onTap: () {
                                                      Get.toNamed(
                                                          Routes.productDetail,
                                                          arguments: {
                                                            "productDetail":
                                                                controller
                                                                        .suggestedProductsList[
                                                                    index]
                                                          });
                                                    },
                                                    child: ProductOutfitCard(
                                                      product: controller
                                                              .suggestedProductsList[
                                                          index],
                                                      isFirst: (controller
                                                                  .currentCardIndex
                                                                  .value ==
                                                              index)
                                                          .obs,
                                                      swipeProgress: double.tryParse(
                                                              percentThresholdX
                                                                  .toString()) ??
                                                          0,
                                                    ),
                                                  ));
                                            },
                                            initialIndex: controller
                                                .currentCardIndex.value,
                                            onSwipe: (previousIndex,
                                                currentIndex, direction) {
                                              final outfitList = controller
                                                  .suggestedProductsList;

                                              if (previousIndex < 0 ||
                                                  previousIndex >=
                                                      outfitList.length) {
                                                return true;
                                              }

                                              // ... (logic for adding to favorite/dislike lists)
                                              if (direction ==
                                                  CardSwiperDirection.right) {
                                                controller.likedProduct(
                                                    outfitList[previousIndex]
                                                            .id ??
                                                        "");
                                              } else if (direction ==
                                                  CardSwiperDirection.left) {
                                                controller.skipProduct(
                                                    outfitList[previousIndex]
                                                            .id ??
                                                        "");
                                              }
                                              controller
                                                  .remainingProductsInQueue
                                                  .value--;

                                              if (controller
                                                          .remainingProductsInQueue
                                                          .value <
                                                      5 &&
                                                  !controller.isLoading.value &&
                                                  !controller
                                                      .isPaginating.value) {
                                                controller.getSuggestedProducts(
                                                    isLoadMore: true);
                                              }

                                              // ... (logic for updating currentCardIndex)
                                              if (currentIndex != null) {
                                                controller.currentCardIndex
                                                    .value = currentIndex;
                                              } else if (currentIndex == null &&
                                                  controller.currentCardIndex
                                                          .value ==
                                                      outfitList.length - 1) {
                                                controller
                                                    .currentCardIndex.value++;
                                              }
                                              return true;
                                            },
                                          ),
                              )))
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

                final slideOffset =
                    currentProgress * 40; // Bottom bar slides less

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
                        )
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
                style: style700S12.copyWith(
                  fontSize: 10,
                  letterSpacing: 0.80,
                ),
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
        Obx(() => TopProgressBar(
              value: controller.currentCardIndex.value,
              maxValue: controller.suggestedProductsList.length,
              height: 50,
            )),
        Padding(
          padding: const EdgeInsets.only(left: 4.5),
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  controller.toggleDrawer();
                },
                child: Obx(() => AppNetworkImage(
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
                    )),
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
                          color: AppColors.whiteColor),
                    ),
                    Obx(() => Text(
                          controller.userName.value
                                  .split(" ")
                                  .first
                                  .capitalizeFirst ??
                              "",
                          style: style600S20.copyWith(
                              letterSpacing: 0.42,
                              color: AppColors.whiteTextColor,
                              height: 1.1),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
