import 'package:flutter/material.dart';
import 'package:vousvous/core/services/haptic_service.dart';
import 'package:vousvous/core/services/performance_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/widgets/lower_clippath.dart';
import 'package:vousvous/core/widgets/upper_clippath.dart';

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
  // --- MODIFIED: This will accumulate the user's drag distance.
  double _panDeltaAccumulator = 0.0;

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

  // --- MODIFIED: Simplified to allow animations to be re-triggered.
  void _triggerSlideAnimation() {
    // Just restart the animation from the beginning.
    _slideController.forward(from: 0.0);
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
          // ... (Your background, blur, and clipper widgets remain unchanged)
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
              filter: PerformanceService.instance.getScaledBlurFilter(20),
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
              // --- MODIFIED: The GestureDetector logic is completely new.
              GestureDetector(
                onPanUpdate: (details) {
                  if (widget.onIndexChanged == null) return;

                  // 1. Accumulate the horizontal drag delta
                  _panDeltaAccumulator += details.delta.dx;

                  // 2. Define a threshold for a swipe action
                  //    (e.g., 1/8th of the screen width)
                  final swipeThreshold = MediaQuery.of(context).size.width / 8;

                  // 3. Check for swipes and update index
                  // Swipe right → previous item
                  if (_panDeltaAccumulator > swipeThreshold) {
                    if (widget.currentIndex > 0) {
                      widget.onIndexChanged!(widget.currentIndex - 1);
                      HapticService.medium();
                      // Decrement accumulator to allow for continuous swiping
                      _panDeltaAccumulator -= swipeThreshold;
                    }
                  }
                  // Swipe left → next item
                  else if (_panDeltaAccumulator < -swipeThreshold) {
                    if (widget.currentIndex < widget.totalItems - 1) {
                      widget.onIndexChanged!(widget.currentIndex + 1);
                      HapticService.medium();
                      // Increment accumulator to allow for continuous swiping
                      _panDeltaAccumulator += swipeThreshold;
                    }
                  }
                },
                onPanEnd: (_) {
                  // Reset accumulator when the gesture ends
                  _panDeltaAccumulator = 0.0;
                },
                onPanCancel: () {
                  // Also reset on cancellation
                  _panDeltaAccumulator = 0.0;
                },
                child: Container(
                  color: Colors.transparent,
                  margin: const EdgeInsets.symmetric(vertical: 10),
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
    // ... (This function remains unchanged)
    final middle = widget.barCount ~/ 2;
    final isMovingLeft = widget.currentIndex > _previousIndex;
    final isMovingRight = widget.currentIndex < _previousIndex;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(widget.barCount, (barIndex) {
        final barHeight = _calculateBarHeight(barIndex);
        final distanceFromCenter = (barIndex - middle).abs();
        final maxDistance = middle.toDouble();

        double baseOpacity;
        if (distanceFromCenter == 0) {
          baseOpacity = 1.0;
        } else {
          final opacityRatio = 1.0 - (distanceFromCenter / maxDistance);
          baseOpacity = 0.2 + (opacityRatio * 0.8);
        }

        double offsetX = 0.0;
        double animationOpacityMultiplier = 1.0;

        if (_slideAnimation.value > 0 && _slideAnimation.value < 1) {
          if (isMovingLeft) {
            offsetX = -20 * (1 - _slideAnimation.value);
            animationOpacityMultiplier = 0.3 + (0.7 * _slideAnimation.value);
          } else if (isMovingRight) {
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
