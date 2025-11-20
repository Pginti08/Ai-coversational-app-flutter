import 'package:flutter/material.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';

class CustomScaffold extends StatefulWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool noPadding;
  final bool isTopEffect;
  final bool isBottomEffect;
  final bool isEffect2;
  final bool isEffect3;
  final bool isTopSafeArea;
  final bool isBottomSafeArea;
  final Color? scaffoldColor;
  bool? resizeToAvoidBottomInset;

  CustomScaffold(
      {Key? key,
      required this.body,
      this.appBar,
      this.bottomNavigationBar,
      this.noPadding = true,
      this.isTopEffect = true,
      this.isBottomEffect = true,
      this.isEffect2 = false,
      this.isEffect3 = false,
      this.isTopSafeArea = true,
      this.isBottomSafeArea = true,
      this.scaffoldColor,
      this.resizeToAvoidBottomInset})
      : super(key: key);

  @override
  State<CustomScaffold> createState() => _CustomScaffoldState();
}

class _CustomScaffoldState extends State<CustomScaffold> {
  @override
  Widget build(BuildContext context) {
    // Get the status bar height
    final statusBarHeight = MediaQuery.paddingOf(context).top;

    // Get AppBar height from the widget itself
    final appBarHeight = (widget.appBar?.preferredSize.height ?? 0) - 10;

    // Get BottomNavigationBar height (render to measure)
    final bottomNavHeight = _getBottomNavHeight();

    // Total top padding (status bar + app bar)
    final topPadding = statusBarHeight + appBarHeight;

    // MODIFIED: The scaffoldColor is now applied directly to the Scaffold's backgroundColor.
    return Scaffold(
      resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
      body: Stack(
        children: [
          Positioned.fill(
              child: Container(
            color: widget.scaffoldColor ?? AppColors.blackColor,
          )),
          Positioned.fill(
            child: Stack(
              children: [
                // Top gradient blur
                if (widget.isTopEffect)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      widget.isEffect2
                          ? AssetConstants.gradientTop2
                          : AssetConstants.gradientTop,
                      width: MediaQuery.sizeOf(context).width,
                      fit: BoxFit.fitWidth,
                    ),
                  ),

                // Bottom gradient blur
                if (widget.isBottomEffect)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Image.asset(
                      widget.isEffect2
                          ? AssetConstants.gradientBottom2
                          : widget.isEffect3
                              ? AssetConstants.gradientBottom3
                              : AssetConstants.gradientBottom,
                      width: MediaQuery.sizeOf(context).width,
                      fit: BoxFit.fitWidth,
                    ),
                  ),

                // Blur layer
              ],
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Main body
              Positioned.fill(
                child: Padding(
                  padding: !widget.noPadding
                      ? EdgeInsets.only(
                          top: topPadding, // Padding for status bar and AppBar
                          bottom:
                              bottomNavHeight, // Padding for BottomNavigationBar
                        )
                      : EdgeInsets.zero,
                  child: SafeArea(
                    top: widget.isTopSafeArea,
                    bottom: widget.isBottomSafeArea,
                    child: widget.body,
                  ),
                ),
              ),

              // AppBar at the top
              if (widget.appBar != null)
                Positioned(top: 0, left: 0, right: 0, child: widget.appBar!),

              // BottomNavigationBar at the bottom
              if (widget.bottomNavigationBar != null)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: widget.bottomNavigationBar!,
                ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to get bottom navigation bar height
  double _getBottomNavHeight() {
    // For BottomNavigationBar, the default height is kBottomNavigationBarHeight (56.0)
    // But we'll add bottom padding for safe area
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return kBottomNavigationBarHeight + bottomPadding;
  }
}
