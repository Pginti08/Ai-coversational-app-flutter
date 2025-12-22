import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/haptic_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/widgets/common_container.dart';

class AnimatedHeartButton extends StatefulWidget {
  final VoidCallback onLiked;
  final Duration animationDuration;
  final Duration delayBeforeAction;

  const AnimatedHeartButton({
    super.key,
    required this.onLiked,
    this.animationDuration = const Duration(milliseconds: 300),
    this.delayBeforeAction = const Duration(milliseconds: 400),
  });

  @override
  State<AnimatedHeartButton> createState() => _AnimatedHeartButtonState();
}

class _AnimatedHeartButtonState extends State<AnimatedHeartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isLiked = false;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _isLiked = true;
    });

    // Haptic feedback
    HapticService.medium();

    // Play animation
    await _controller.forward();

    // Wait for delay before calling the action
    await Future.delayed(widget.delayBeforeAction);

    // Call the callback
    widget.onLiked();

    // Reset animation controller but keep heart liked (red)
    _controller.reset();
    setState(() {
      _isAnimating = false;
      // Don't reset _isLiked - keep it true so heart stays filled
    });
  }

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      onTap: _handleTap,
      isCircle: true,
      borderGradientColors: const [
        Color.fromARGB(20, 0, 0, 0),
        Color.fromARGB(30, 0, 0, 0),
        Color.fromARGB(40, 0, 0, 0),
      ],
      gradientColors: const [
        Color.fromARGB(10, 0, 0, 0),
        Color.fromARGB(20, 0, 0, 0),
        Color.fromARGB(30, 0, 0, 0),
      ],
      padding: const EdgeInsets.all(8),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: SvgPicture.asset(
              _isLiked ? AssetConstants.heart : AssetConstants.heart2,
              colorFilter: ColorFilter.mode(
                _isLiked ? Colors.red : AppColors.whiteColor,
                BlendMode.srcIn,
              ),
            ),
          );
        },
      ),
    );
  }
}
