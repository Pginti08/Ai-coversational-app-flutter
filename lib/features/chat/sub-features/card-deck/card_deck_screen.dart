import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/blur_scaffold.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/stacked_card_widget.dart';
import 'package:vousvous/features/chat/controller/chat_controller.dart';
import 'package:vousvous/features/chat/sub-features/card-deck/controller/card_deck_controller.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/home/widgets/product_outfit_card.dart';
import 'package:vousvous/routes/app_pages.dart';

class CardDeckScreen extends StatefulWidget {
  const CardDeckScreen({super.key});

  @override
  State<CardDeckScreen> createState() => _CardDeckScreenState();
}

class _CardDeckScreenState extends State<CardDeckScreen> {
  final controller = Get.put(CardDeckController());
  @override
  Widget build(BuildContext context) {
    return BlurScaffold(
      overlayColor: AppColors.blackColor.withAlpha(30),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SafeArea(
              bottom: false,
              child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: SvgPicture.asset(AssetConstants.closeIcon)),
            ),
            hSizedBox10,
            Expanded(
              child: CardSwiper(
                controller: controller.cardSwiperController,
                padding: EdgeInsets.zero,
                numberOfCardsDisplayed: controller.outfits.length < 4
                    ? controller.outfits.length
                    : 4,
                scale: 0.97,
                backCardOffset: Offset(0, 25),
                allowedSwipeDirection:
                    AllowedSwipeDirection.only(left: true, right: true),
                cardsCount: controller.outfits.length,
                isLoop: true,
                cardBuilder:
                    (context, index, percentThresholdX, percentThresholdY) {
                  return ProductOutfitCard(
                    product: Product(image: "${controller.outfits[index]}"),
                    isFirst: (controller.currentCardIndex.value == index).obs,
                    swipeProgress:
                        double.tryParse(percentThresholdX.toString()) ?? 0,
                    onTap: () {
                      Get.toNamed(Routes.remixedProduct, arguments: {
                        "imageUrl": "${controller.outfits[index]}"
                      });
                    },
                  );
                },
                initialIndex: controller.currentCardIndex.value,
                onSwipe: (previousIndex, currentIndex, direction) {
                  final outfitList = controller.outfits;

                  if (previousIndex < 0 || previousIndex >= outfitList.length) {
                    return true;
                  }

                  if (direction == CardSwiperDirection.right) {
                    controller.addToRemix();
                  } else if (direction == CardSwiperDirection.left) {
                    controller.removeFromRemix();
                  }

                  // Safely update currentCardIndex
                  if (currentIndex != null) {
                    controller.currentCardIndex.value = currentIndex;
                  } else if (currentIndex == null &&
                      controller.currentCardIndex.value ==
                          outfitList.length - 1) {
                    controller.currentCardIndex.value++;
                  }
                  return true;
                },
              ),
            ),
            SizedBox(
              height: 80.h,
            ),
            SafeArea(
              top: false,
              child: Obx(() => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        controller.remixOutfits.isEmpty
                            ? AppButton(
                                height: 52,
                                width: 170.w,
                                onTap: () {
                                  controller.cardSwiperController
                                      .swipe(CardSwiperDirection.right);
                                },
                                gradientBorderColors: AppColors.colorGradient,
                                isOutlined: true,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        AssetConstants.magicpen,
                                        color: AppColors.whiteColor,
                                      ),
                                      wSizedBox2,
                                      Text(
                                        "Remix",
                                        style: style700S14,
                                      )
                                    ],
                                  ),
                                ),
                              )
                            : Row(
                                children: [
                                  CommonContainer(
                                    onTap: () {
                                      controller.clearRemixOutfits();
                                    },
                                    enableBlur: true,
                                    padding: EdgeInsets.all(10),
                                    isCircle: true,
                                    height: 52,
                                    width: 52,
                                    borderGradientColors:
                                        AppColors.glassBorderGradient,
                                    child: SvgPicture.asset(
                                      AssetConstants.rotateLeft,
                                      height: 28,
                                    ),
                                  ),
                                  wSizedBox10,
                                  controller.remixOutfits.contains(controller
                                              .outfits[
                                          controller.currentCardIndex.value])
                                      ? CommonContainer(
                                          onTap: () {
                                            controller.cardSwiperController
                                                .swipe(
                                                    CardSwiperDirection.left);
                                          },
                                          enableBlur: true,
                                          padding: EdgeInsets.all(10),
                                          isCircle: true,
                                          height: 52,
                                          width: 52,
                                          borderGradientColors:
                                              AppColors.colorGradient,
                                          child: SvgPicture.asset(
                                            AssetConstants.minus,
                                            height: 28,
                                          ),
                                        )
                                      : CommonContainer(
                                          onTap: () {
                                            controller.cardSwiperController
                                                .swipe(
                                                    CardSwiperDirection.right);
                                          },
                                          enableBlur: true,
                                          padding: EdgeInsets.all(10),
                                          isCircle: true,
                                          height: 52,
                                          width: 52,
                                          borderGradientColors:
                                              AppColors.colorGradient,
                                          child: SvgPicture.asset(
                                            AssetConstants.add,
                                            height: 28,
                                          ),
                                        ),
                                  wSizedBox10,
                                  AppButton(
                                    height: 52,
                                    onTap: () {
                                      Get.back();
                                      if (Get.isRegistered<ChatController>()) {
                                        Get.find<ChatController>()
                                                .userSelectedRemixOutfits =
                                            controller.remixOutfits;
                                      } else {
                                        Get.put(ChatController())
                                                .userSelectedRemixOutfits =
                                            controller.remixOutfits;
                                      }
                                      WidgetsBinding.instance
                                          .addPostFrameCallback((_) {
                                        Get.find<ChatController>()
                                            .typeFocusNode
                                            .requestFocus();
                                      });
                                    },
                                    gradientBorderColors:
                                        AppColors.colorGradient,
                                    isOutlined: true,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 8),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 24,
                                            height: 36,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              boxShadow: [
                                                // First shadow layer, using the first color of your gradient
                                                BoxShadow(
                                                  color: AppColors
                                                      .colorGradient[0]
                                                      .withAlpha(50),
                                                  blurRadius: 5,
                                                  spreadRadius: 3,
                                                  offset: const Offset(-3, 0),
                                                ),
                                                // Second shadow layer, using the second color of your gradient
                                                BoxShadow(
                                                  color: AppColors
                                                      .colorGradient[1]
                                                      .withAlpha(50),
                                                  blurRadius: 5,
                                                  spreadRadius: 3,
                                                  offset: const Offset(3, 0),
                                                ),
                                              ],
                                            ),
                                            child: Obx(() => CardDeckWidget(
                                                  items: controller.remixOutfits
                                                      .map((e) => e)
                                                      .toList()
                                                      .obs,
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
                                                      width: 24,
                                                      height: 36,
                                                    ),
                                                  ),
                                                )),
                                          ),
                                          wSizedBox6,
                                          Text(
                                            "Remix Selected",
                                            style: style700S14,
                                          ),
                                          wSizedBox4,
                                          SvgPicture.asset(
                                            AssetConstants.arrowRight,
                                            color: AppColors.whiteColor,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              )
                      ],
                    ),
                  )),
            )
          ],
        ),
      ),
    );
  }
}
