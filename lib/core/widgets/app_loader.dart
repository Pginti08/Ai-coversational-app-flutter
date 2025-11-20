import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vousvous/core/theme/app_colors.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return RepaintBoundary(
      child: AbsorbPointer(
        absorbing: true,
        child: PopScope(
          canPop: false,
          child: RepaintBoundary(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                height: height,
                width: width,
                color: AppColors.blackColor.withAlpha(10),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: const RotatingLoader(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RotatingLoader extends StatelessWidget {
  const RotatingLoader({super.key, this.size = 40});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: AppColors.secondaryColor,
      ),
    );
  }
}
