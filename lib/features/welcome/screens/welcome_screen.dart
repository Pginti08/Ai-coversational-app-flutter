import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/core/widgets/swipe_right_button.dart';
import 'package:vousvous/features/welcome/controller/welcome_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final WelcomeController controller = Get.put(WelcomeController());

  final List<WelcomePage> pages = [
    WelcomePage(
      title: "Change your perspective in style",
      description:
          "Change the quality of your vibe & appearance with ‘App Name’ now!",
      image: AssetConstants.welcome1,
    ),
    WelcomePage(
      title: "Let’s Vibe with Fashion",
      description: "Change the quality of your appearance with “app name” now!",
      image: AssetConstants.welcome2,
    ),
  ];

  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoChange();
  }

  void _startAutoChange() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      setState(() {
        _currentPage = (_currentPage + 1) % pages.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return CustomScaffold(
      isBottomEffect: false,
      isBottomSafeArea: false,
      body: Stack(
        children: [
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 4,
                    width: 27,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? Colors.white
                          : Colors.white.withAlpha(50),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              hSizedBox30,
              Expanded(
                child: Stack(
                  children: [
                    /// Fade animation for each page
                    ...List.generate(pages.length, (index) {
                      final page = pages[index];
                      return AnimatedOpacity(
                        duration: const Duration(milliseconds: 600),
                        opacity: _currentPage == index ? 1.0 : 0.0,
                        child: Container(
                          width: screenWidth,
                          height: screenHeight,
                          color: Colors.transparent,
                          child: Stack(
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(left: 16.w, right: 50.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(page.title.toUpperCase(),
                                        style: style600S20.copyWith(
                                            fontSize: 26,
                                            color: Color(0xFFECECEC),
                                            height: 1.38)),
                                    hSizedBox8,
                                    Padding(
                                      padding: EdgeInsets.only(right: 70.w),
                                      child: Text(page.description,
                                          style: style400S12.copyWith(
                                              color: Color(0xFFECECEC),
                                              height: 1.50)),
                                    ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 90.h,
                                child: Container(
                                  width: MediaQuery.sizeOf(context).width,
                                  child: Image.asset(
                                    page.image,
                                    fit: BoxFit.fitWidth,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            right: 100,
            child: Container(
              width: screenWidth * 0.4,
              height: screenWidth * 0.1,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(-50, 0),
                    color: AppColors.primaryColor.withAlpha(50),
                    blurRadius: 80,
                    spreadRadius: 100,
                  ),
                  BoxShadow(
                    offset: Offset(50, 0),
                    color: AppColors.secondaryColor.withAlpha(50),
                    blurRadius: 80,
                    spreadRadius: 100,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            bottom: Platform.isAndroid ? 10 : 0,
            child: SafeArea(
              top: false,
              child: SwipeSliderButton(
                title: 'Slide to continue',
                backgroundColor: AppColors.blackColor,
                unfilledColor: AppColors.blackColor,
                width: MediaQuery.sizeOf(context).width * 0.7,
                height: 68,
                onSwipe: () {
                  Get.offNamed(Routes.login);
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}

class WelcomePage {
  final String title;
  final String description;
  final String image;

  WelcomePage({
    required this.title,
    required this.description,
    required this.image,
  });
}
