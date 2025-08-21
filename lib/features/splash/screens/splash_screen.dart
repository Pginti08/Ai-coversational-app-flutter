import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/features/splash/controller/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final SplashController controller = Get.put(SplashController());

  late AnimationController _animController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Top circle moves downward and back up
          final topOffset =
              -(screenWidth * 0.1) + (_animation.value * (screenHeight / 2));

          // Bottom circle moves upward and back down
          final bottomOffset =
              -(screenWidth * 0.1) + (_animation.value * (screenHeight / 2));

          return Container(
            height: screenHeight,
            width: screenWidth,
            color: AppColors.blackColor,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Top glowing circle
                Positioned(
                  top: topOffset,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryColor.withAlpha(100),
                          blurRadius: 100,
                          spreadRadius: 120,
                        ),
                      ],
                    ),
                  ),
                ),

                // Bottom glowing circle
                Positioned(
                  bottom: bottomOffset,
                  left: 0,
                  right: 0,
                  child: Container(
                    width: screenWidth * 0.2,
                    height: screenWidth * 0.2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondaryColor.withAlpha(100),
                          blurRadius: 100,
                          spreadRadius: 120,
                        ),
                      ],
                    ),
                  ),
                ),

                // Center logo text
                Center(
                  child: Text("Logo",
                      style: GoogleFonts.redressed(
                        color: AppColors.whiteTextColor,
                        fontSize: 80,
                        fontWeight: FontWeight.w400,
                      )),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
