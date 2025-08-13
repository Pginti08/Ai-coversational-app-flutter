import 'dart:ui';

import 'package:flutter/material.dart';

class GlobalLoader extends StatelessWidget {
  const GlobalLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return RepaintBoundary(
      child: AbsorbPointer(
        absorbing: true,
        child: PopScope(
          canPop: false,
          child: RepaintBoundary(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: SizedBox(
                height: height,
                width: width,
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
  const RotatingLoader({super.key, this.size = 100});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }
}
