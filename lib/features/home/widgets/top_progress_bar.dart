import 'dart:ui';

import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class TopProgressBar extends StatefulWidget {
  final int value;
  final int maxValue;
  final double height;
  final double borderRadius;
  final double baseWidth;
  final Duration animationDuration;
  final Color? backgroundColor;
  final List<Color>? progressColors;
  final ValueChanged<int>? onValueChanged;

  const TopProgressBar({
    Key? key,
    required this.value,
    this.maxValue = 10,
    this.height = 50.0,
    this.borderRadius = 100.0,
    this.baseWidth = 50.0,
    this.animationDuration = const Duration(milliseconds: 800),
    this.backgroundColor,
    this.progressColors, // Removed default AppColors reference
    this.onValueChanged,
  }) : super(key: key);

  @override
  State<TopProgressBar> createState() => _TopProgressBarState();
}

class _TopProgressBarState extends State<TopProgressBar>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentValue = 0;
  double _containerWidth = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    // Initialize animation with base width, will be updated in didChangeDependencies
    _animation = Tween<double>(
      begin: widget.baseWidth,
      end: widget.baseWidth,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Now MediaQuery is available
    _containerWidth = MediaQuery.sizeOf(context).width;

    // Update animation with correct width calculation
    final targetWidth = _calculateWidth(_currentValue);
    _animation = Tween<double>(
      begin: targetWidth,
      end: targetWidth,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(TopProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _updateValue(widget.value);
    }
    if (oldWidget.animationDuration != widget.animationDuration) {
      _controller.duration = widget.animationDuration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _calculateWidth(int val) {
    if (val == 0) return widget.baseWidth;
    if (_containerWidth == 0) return widget.baseWidth; // Fallback

    final remainingWidth = _containerWidth - widget.baseWidth;
    final clampedVal = val.clamp(0, widget.maxValue);
    return widget.baseWidth + (remainingWidth * clampedVal / widget.maxValue);
  }

  void _updateValue(int newValue) {
    if (!mounted) return; // Safety check

    setState(() {
      final oldWidth = _animation.value;
      final newWidth = _calculateWidth(newValue);

      _animation = Tween<double>(
        begin: oldWidth,
        end: newWidth,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));

      _currentValue = newValue;
      _controller.reset();
      _controller.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          width: MediaQuery.sizeOf(context).width,
          height: widget.height,
          decoration: BoxDecoration(
            color:
                widget.backgroundColor ?? AppColors.grey2Color.withAlpha(120),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: GradientBoxBorder(
              width: 1,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: AppColors.glassBorderGradient,
              ),
            ),
          ),
          child: Stack(
            children: [
              // Animated Fill
              AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return Opacity(
                    opacity: 0.4,
                    child: Container(
                      width: _animation.value,
                      height: widget.height,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(widget.borderRadius),
                        gradient: LinearGradient(
                          colors:
                              widget.progressColors ?? AppColors.colorGradient,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
