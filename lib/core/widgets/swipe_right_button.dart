import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/widgets/shimmer_utils.dart';

class SwipeSliderButton extends StatefulWidget {
  final String title;
  final Color backgroundColor;
  final Color unfilledColor;
  final VoidCallback onSwipe;
  final double width;
  final double height;
  final TextStyle? textStyle;
  final double borderRadius;
  final IconData icon;
  final bool enableBlur; // Added for glassmorphism

  const SwipeSliderButton({
    super.key,
    required this.title,
    required this.onSwipe,
    this.width = 300,
    this.height = 70,
    this.backgroundColor = Colors.deepPurple,
    this.unfilledColor = const Color(0xFF2E2E2E),
    this.textStyle,
    this.borderRadius = 100,
    this.icon = Icons.chevron_right,
    this.enableBlur = false, // Defaults to false
  });

  @override
  State<SwipeSliderButton> createState() => _SwipeSliderButtonState();
}

class _SwipeSliderButtonState extends State<SwipeSliderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  double _dragPosition = 0.0;
  bool _isCompleted = false;

  // The maximum distance the handle can be dragged.
  double get _maxDragDistance => widget.width - widget.height;
  // The threshold (80% of the way) to trigger a successful swipe.
  double get _threshold => _maxDragDistance * 0.8;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Use the animation controller to update the drag position for smooth animations.
    _animationController.addListener(() {
      if (mounted) {
        setState(() {
          _dragPosition = _animationController.value * _maxDragDistance;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    if (_isCompleted) return;
    _animationController.stop();
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isCompleted) return;
    setState(() {
      _dragPosition += details.delta.dx;
      _dragPosition = _dragPosition.clamp(0.0, _maxDragDistance);
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isCompleted) return;

    if (_dragPosition >= _threshold) {
      _completeSwipe();
    } else {
      _resetSwipe();
    }
  }

  void _completeSwipe() {
    _animationController
        .forward(from: _dragPosition / _maxDragDistance)
        .whenComplete(() {
      if (mounted) {
        setState(() {
          _isCompleted = true;
        });
        widget.onSwipe();
      }
    });
  }

  void _resetSwipe() {
    _animationController.reverse(from: _dragPosition / _maxDragDistance);
  }

  Widget _buildBlurEffect(Widget child) {
    if (widget.enableBlur) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: child,
        ),
      );
    }
    return child;
  }

  @override
  Widget build(BuildContext context) {
    return _buildBlurEffect(
      Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.unfilledColor,
          borderRadius: BorderRadius.horizontal(
              left: Radius.circular(widget.borderRadius)),
          border: widget.enableBlur
              ? Border.all(
                  color: Colors.white.withAlpha(25),
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignOutside)
              : null,
          boxShadow: [
            if (!widget.enableBlur)
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 10,
                spreadRadius: 2,
              )
          ],
        ),
        // ADDED: ClipRRect to enforce rounded corners on children.
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 1. Progressive Fill Container
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: _dragPosition + widget.height,
                  height: widget.height,
                  decoration: BoxDecoration(
                    // FIXED: Added the background color to make the fill visible.
                    color: widget.backgroundColor,
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                ),
              ),

              // 2. Text Layer with Fade Transition
              AnimatedOpacity(
                opacity: _isCompleted ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: Padding(
                  padding: const EdgeInsets.only(left: 30),
                  child: shimmer(
                    color: AppColors.whiteColor,
                    child: Text(
                      widget.title,
                      // Using a default style if none is provided.
                      style: widget.textStyle ??
                          style500S16.copyWith(letterSpacing: 0.60),
                    ),
                  ),
                ),
              ),

              // 3. Draggable Handle
              AnimatedOpacity(
                opacity: _isCompleted ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 250),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Transform.translate(
                    offset: Offset(_dragPosition, 0),
                    child: GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: Container(
                        width: widget.height - 10, // Slightly smaller
                        height: widget.height - 10,
                        margin: EdgeInsets.all(5),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              center: Alignment.topLeft,
                              radius: 1.2,
                              colors: [
                                Colors.white,
                                Color(0xFFE0E0E0),
                                Color(0xFFB0B0B0),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withAlpha(50),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: Offset(2, 2),
                              ),
                            ]),
                        child: Center(
                          child: Transform.rotate(
                              angle: 0, // No rotation needed for forward icon
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.black87,
                                size: 24,
                              )
                              // SvgPicture.asset(
                              //   AssetConstants.backward, // Keeping original for now or swap to arrow
                              //   color: AppColors.blackColor, // Dark icon on light bg
                              // ),
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
