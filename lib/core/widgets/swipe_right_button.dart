import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/widgets/shimmer_utils.dart';

// Note: I've replaced your custom assets and styles with standard ones
// to make this example self-contained and runnable.

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

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.unfilledColor,
        borderRadius:
            BorderRadius.horizontal(left: Radius.circular(widget.borderRadius)),
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
                      width: widget.height,
                      height: widget.height,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.black,
                              const Color(0xFF0D0D0D),
                              const Color(0xFF191919),
                            ],
                          ),
                          border: Border.all(
                              color: AppColors.whiteColor.withAlpha(15)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.whiteColor.withAlpha(25),
                              blurRadius: 5,
                              spreadRadius: 5,
                            ),
                          ]),
                      child: Center(
                        child: Transform.rotate(
                          angle: 3.14159,
                          child: SvgPicture.asset(
                            AssetConstants.backward,
                            color: AppColors.whiteColor,
                          ),
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
    );
  }
}
