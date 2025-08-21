import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/animated_curved_bar_indicator.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/core/widgets/stacked_card_widget.dart';
import 'package:ai_fashion/features/my-designs/controller/my_designs_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class MyDesignsScreen extends StatelessWidget {
  MyDesignsScreen({super.key});
  final MyDesignsController controller = Get.put(MyDesignsController());
  final CarouselSliderController carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        isBottomEffect: false,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('My Designs',
                      textAlign: TextAlign.center,
                      style: style700S28.copyWith(color: AppColors.textColor)),
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: SvgPicture.asset(AssetConstants.closeIcon),
                  )
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                if (controller.myDesignsList.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'No yours designs available',
                          style: style500S16.copyWith(
                            color: AppColors.textColor.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return CarouselSlider.builder(
                  carouselController: carouselController,
                  itemCount: controller.myDesignsList.length,
                  itemBuilder: (context, index, realIndex) {
                    return Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: AppNetworkImage(
                              imageUrl:
                                  controller.myDesignsList[index].imageUrl ??
                                      "",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 0,
                            right: 0,
                            left: 0,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: CommonContainer(
                                blurStrength: 40,
                                enableBlur: true,
                                borderRadius: 100,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                borderColor: AppColors.whiteColor.withAlpha(50),
                                backgroundColor:
                                    AppColors.whiteColor.withAlpha(20),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        controller.myDesignsList[index].title ??
                                            "",
                                        overflow: TextOverflow.ellipsis,
                                        style: style500S16.copyWith(
                                            letterSpacing: 0.32),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ))
                      ],
                    );
                  },
                  options: CarouselOptions(
                    aspectRatio: 0.8,
                    viewportFraction: 0.8,
                    initialPage: 0,
                    enableInfiniteScroll:
                        true, // Changed to false for better indicator sync
                    reverse: false,
                    autoPlay: false,
                    autoPlayInterval: const Duration(seconds: 3),
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 800),
                    autoPlayCurve: Curves.fastOutSlowIn,
                    enlargeCenterPage: true,
                    enlargeFactor: 0.25,
                    scrollDirection: Axis.horizontal,
                    onPageChanged: (index, reason) {
                      controller.currentCarouselIndex.value = index;
                    },
                  ),
                );
              }),
            ),
            hSizedBox18,
            Obx(() => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      controller.remixOutfits.isEmpty
                          ? AppButton(
                              height: 52,
                              width: 170.w,
                              onTap: () {
                                controller.addToRemix(carouselController);
                              },
                              gradientBorderColors: AppColors.colorGradient,
                              isOutlined: true,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
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
                                wSizedBox12,
                                CommonContainer(
                                  onTap: () {
                                    controller.addToRemix(carouselController);
                                  },
                                  enableBlur: true,
                                  padding: EdgeInsets.all(10),
                                  isCircle: true,
                                  height: 52,
                                  width: 52,
                                  borderGradientColors: AppColors.colorGradient,
                                  child: SvgPicture.asset(
                                    AssetConstants.add,
                                    height: 28,
                                  ),
                                ),
                                wSizedBox12,
                                AppButton(
                                  height: 52,
                                  onTap: () {},
                                  gradientBorderColors: AppColors.colorGradient,
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
                                                    .map(
                                                        (e) => e.imageUrl ?? "")
                                                    .toList()
                                                    .obs,
                                                itemBuilder: (imageUrl) =>
                                                    ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  child: AppNetworkImage(
                                                    imageUrl: imageUrl,
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

            // Curved Bar Indicator
            Obx(() {
              if (controller.myDesignsList.isEmpty) {
                return SizedBox.shrink();
              }

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: AnimatedCurvedBarIndicator(
                  currentIndex: controller.currentCarouselIndex.value,
                  totalItems: controller.myDesignsList.length,
                  barCount: 19,
                  maxHeight: 55,
                  minHeight: 35,
                  barWidth: 5,
                  activeColor: AppColors.whiteColor,
                  inactiveColor: AppColors.whiteColor.withOpacity(0.2),
                  duration: Duration(milliseconds: 300),
                  onIndexChanged: (newIndex) {
                    controller.currentCarouselIndex.value = newIndex;
                    carouselController.animateToPage(
                      newIndex,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              );
            }),
          ],
        ));
  }
}
