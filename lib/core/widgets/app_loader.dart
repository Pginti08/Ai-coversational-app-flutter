import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: true,
      child: PopScope(
        canPop: false,
        child: Stack(
          children: [
            // Black overlay below
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(150),
              ),
            ),
            // Indicator on top
            Center(
              child: const RotatingLoader(),
            ),
          ],
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
        color: const Color(0xFFB17534),
      ),
    );
  }
}
