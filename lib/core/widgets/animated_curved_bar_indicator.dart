import 'dart:ui';

import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/widgets/lower_clippath.dart';
import 'package:ai_fashion/core/widgets/upper_clippath.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedCurvedBarIndicator extends StatefulWidget {
  final int currentIndex;
  final int totalItems;
  final int barCount;
  final Duration duration;
  final double maxHeight;
  final double minHeight;
  final Color activeColor;
  final Color inactiveColor;
  final double barWidth;
  final Function(int)? onIndexChanged;

  const AnimatedCurvedBarIndicator({
    Key? key,
    required this.currentIndex,
    required this.totalItems,
    this.barCount = 7,
    this.duration = const Duration(milliseconds: 300),
    this.maxHeight = 55,
    this.minHeight = 25,
    this.activeColor = Colors.white,
    this.inactiveColor = const Color(0x33FFFFFF),
    this.barWidth = 3,
    this.onIndexChanged,
  })  : assert(barCount % 2 == 1, "barCount must be an odd number."),
        super(key: key);

  @override
  State<AnimatedCurvedBarIndicator> createState() =>
      _AnimatedCurvedBarIndicatorState();
}

class _AnimatedCurvedBarIndicatorState extends State<AnimatedCurvedBarIndicator>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;
  int _previousIndex = 0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _previousIndex = widget.currentIndex;

    _slideController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedCurvedBarIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.currentIndex != widget.currentIndex) {
      _previousIndex = oldWidget.currentIndex;
      _triggerSlideAnimation();
    }
  }

  void _triggerSlideAnimation() {
    if (!_isAnimating) {
      _isAnimating = true;
      _slideController.forward(from: 0.0).then((_) {
        _isAnimating = false;
      });
    }
  }

  @override
  void dispose() {
    _slideController.dispose();
    super.dispose();
  }

  double _calculateBarHeight(int barIndex) {
    final middle = widget.barCount ~/ 2;

    // Distance from center (0 at center, increases towards edges)
    final distanceFromCenter = (barIndex - middle).abs();

    // Create a curve where center is smallest, edges are tallest
    final heightRatio = distanceFromCenter / middle;

    // Invert the ratio so center gets minHeight, edges get maxHeight
    return widget.minHeight +
        (heightRatio * (widget.maxHeight - widget.minHeight));
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Opacity(
            opacity: 0.25,
            child: Container(
              height: widget.minHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(300),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [
                    Color(0xFF3FA1C7),
                    Color(0xFFFFB86B),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Container(color: Colors.transparent),
            ),
          ),
          Column(
            children: [
              Stack(
                children: [
                  ClipPath(
                    clipper: LowerClipPathClass(15),
                    child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          colors: AppColors.lineGradient,
                        ))),
                  ),
                  ClipPath(
                    clipper: LowerClipPathClass(15),
                    child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.blackColor,
                        )),
                  ),
                ],
              ),
              GestureDetector(
                onPanUpdate: (details) {
                  if (widget.onIndexChanged != null && !_isAnimating) {
                    final sensitivity = 0.5;
                    final deltaX = details.delta.dx;

                    if (deltaX > sensitivity) {
                      // Swipe right
                      final newIndex = widget.currentIndex > 0
                          ? widget.currentIndex - 1
                          : widget.totalItems - 1; // Wrap to last item
                      widget.onIndexChanged!(newIndex);
                      HapticFeedback.mediumImpact();
                    } else if (deltaX < -sensitivity) {
                      // Swipe left
                      final newIndex =
                          widget.currentIndex < widget.totalItems - 1
                              ? widget.currentIndex + 1
                              : 0; // Wrap to first item
                      widget.onIndexChanged!(newIndex);
                      HapticFeedback.mediumImpact();
                    }
                  }
                },
                child: Container(
                  color: Colors.transparent,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AnimatedBuilder(
                    animation: _slideAnimation,
                    builder: (context, child) {
                      return _buildBars();
                    },
                  ),
                ),
              ),
              Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  ClipPath(
                    clipper: UpperClipPathClass(15),
                    child: Container(
                        height: 12,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          colors: AppColors.lineGradient,
                        ))),
                  ),
                  ClipPath(
                    clipper: UpperClipPathClass(15),
                    child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.blackColor,
                        )),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBars() {
    final middle = widget.barCount ~/ 2;
    final isMovingLeft = widget.currentIndex > _previousIndex;
    final isMovingRight = widget.currentIndex < _previousIndex;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.barCount, (barIndex) {
        // Calculate bar height based on distance from center
        final barHeight = _calculateBarHeight(barIndex);

        // Calculate opacity based on distance from center
        final distanceFromCenter = (barIndex - middle).abs();
        final maxDistance = middle.toDouble();

        // Center bar has full opacity (1.0), edges have minimum opacity
        double baseOpacity;
        if (distanceFromCenter == 0) {
          baseOpacity = 1.0; // Center bar - full opacity
        } else {
          // Gradual decrease from center to edges
          final opacityRatio = 1.0 - (distanceFromCenter / maxDistance);
          baseOpacity = 0.2 + (opacityRatio * 0.8); // Range from 0.2 to 1.0
        }

        // Animation offset for sliding effect
        double offsetX = 0.0;
        double animationOpacityMultiplier = 1.0;

        if (_slideAnimation.value > 0 && _slideAnimation.value < 1) {
          if (isMovingLeft) {
            // Sliding left animation
            offsetX = -20 * (1 - _slideAnimation.value);
            animationOpacityMultiplier = 0.3 + (0.7 * _slideAnimation.value);
          } else if (isMovingRight) {
            // Sliding right animation
            offsetX = 20 * (1 - _slideAnimation.value);
            animationOpacityMultiplier = 0.3 + (0.7 * _slideAnimation.value);
          }
        }

        final finalOpacity = baseOpacity * animationOpacityMultiplier;

        return Transform.translate(
          offset: Offset(offsetX, 0),
          child: AnimatedContainer(
            duration: widget.duration,
            width: widget.barWidth,
            height: barHeight,
            decoration: BoxDecoration(
              color: widget.activeColor.withOpacity(finalOpacity / 1.5),
              boxShadow: barIndex == middle
                  ? [
                      BoxShadow(
                        color: widget.activeColor.withAlpha(150),
                        blurRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      }),
    );
  }
}
