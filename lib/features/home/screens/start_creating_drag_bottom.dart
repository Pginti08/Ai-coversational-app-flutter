import 'dart:ui';

import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class StartCreatingDragBottom extends StatefulWidget {
  const StartCreatingDragBottom({super.key});

  @override
  State<StartCreatingDragBottom> createState() =>
      _StartCreatingDragBottomState();
}

class _StartCreatingDragBottomState extends State<StartCreatingDragBottom>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _stretchAnimation;

  double _stretchHeight = 0;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _stretchAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    // Only allow upward dragging (negative delta for bottom-to-top)
    if (details.delta.dy < 0) {
      setState(() {
        _stretchHeight += details.delta.dy.abs() * 0.5;
        _stretchHeight = _stretchHeight.clamp(0.0, 30.0);
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    // Trigger navigation if stretched enough
    if (_stretchHeight > 20) {
      Get.toNamed(Routes.chat);
    }

    // Animate back to 0
    _stretchAnimation = Tween<double>(begin: _stretchHeight, end: 0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward().then((_) {
      setState(() {
        _stretchHeight = 0;
      });
      _animationController.reset();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(24),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: GestureDetector(
          onTap: () {
            Get.toNamed(Routes.chat);
          },
          onVerticalDragUpdate: _handleDragUpdate,
          onVerticalDragEnd: _handleDragEnd,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6)
                .copyWith(bottom: 0),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(10),
              border: GradientBoxBorder(
                width: 1,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: AppColors.glassBorderGradient,
                ),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Stretch container (animated) - placed at top

                  // Drag indicator with visual feedback
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    width: 40,
                    height: 4,
                    decoration: ShapeDecoration(
                      color: _stretchHeight > 0
                          ? Colors.white.withAlpha(120)
                          : Colors.white.withAlpha(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _stretchAnimation,
                    builder: (context, child) {
                      double currentHeight = _animationController.isAnimating
                          ? _stretchAnimation.value
                          : _stretchHeight;

                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 50),
                        height: currentHeight,
                        color: Colors.transparent,
                      );
                    },
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Start Creating...",
                        style: style400S16.copyWith(letterSpacing: 0.32),
                      ),
                      IconButton(
                        onPressed: () {
                          Get.toNamed(Routes.chat);
                        },
                        icon: SvgPicture.asset(
                          AssetConstants.voiceCircleIcon,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
