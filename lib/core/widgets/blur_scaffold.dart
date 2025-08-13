import 'dart:ui';

import 'package:flutter/material.dart';

class BlurScaffold extends StatefulWidget {
  final Widget body;
  final VoidCallback? onClose;
  final Color overlayColor;
  final double blurStrength;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final bool? resizeToAvoidBottomInset;
  final double appBarBorderRadius; // New parameter for AppBar corner radius

  BlurScaffold({
    super.key,
    required this.body,
    this.onClose,
    this.appBar,
    this.bottomNavigationBar,
    this.overlayColor = const Color.fromARGB(12, 255, 255, 255),
    this.blurStrength = 50.0,
    this.resizeToAvoidBottomInset,
    this.appBarBorderRadius = 24.0, // Default radius matching CustomAppBar
  });

  @override
  State<BlurScaffold> createState() => _BlurScaffoldState();
}

class _BlurScaffoldState extends State<BlurScaffold>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final AnimationController _blurController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _blurController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _scaleAnimation = Tween(begin: 0.95, end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _blurAnimation = Tween(begin: 0.0, end: widget.blurStrength).animate(
      CurvedAnimation(parent: _blurController, curve: Curves.easeOutCubic),
    );

    _blurController.forward();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _blurController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _blurAnimation,
          builder: (context, child) {
            return BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: _blurAnimation.value,
                sigmaY: _blurAnimation.value,
              ),
              child: Container(color: widget.overlayColor),
            );
          },
        ),
        Scaffold(
          resizeToAvoidBottomInset: widget.resizeToAvoidBottomInset,
          backgroundColor: Colors.transparent,
          appBar: widget.appBar,
          body: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            onTap: () => FocusScope.of(context).unfocus(),
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, _) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: widget.appBar != null
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft:
                                    Radius.circular(widget.appBarBorderRadius),
                                topRight:
                                    Radius.circular(widget.appBarBorderRadius),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: widget.body,
                          )
                        : widget.body,
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: widget.bottomNavigationBar,
        ),
      ],
    );
  }
}
