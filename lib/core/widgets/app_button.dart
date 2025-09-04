import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    this.text,
    this.child,
    this.onTap,
    this.isOutlined = false,
    this.isLoading = false,
    this.isDisabled = false,
    this.isGradientBorder = true,
    this.width,
    this.gradientBorderColors,
    this.height,
    this.backgroundColor,
    this.gradientColors,
    this.textColor,
    this.loaderColor,
    this.borderColor,
    this.borderRadius = 100.0,
    this.fontSize = 16.0,
    this.padding,
  });

  final String? text; // Nullable text
  final Widget? child; // New child widget support
  final VoidCallback? onTap;
  final bool isOutlined;
  final bool isLoading;
  final bool isDisabled;
  final bool isGradientBorder;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final List<Color>? gradientColors;
  final List<Color>? gradientBorderColors;
  final Color? textColor;
  final Color? loaderColor;
  final Color? borderColor;
  final double borderRadius;
  final double fontSize;
  final EdgeInsetsGeometry? padding;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.reverse();
    }
  }

  void _handleTapCancel() {
    if (!widget.isDisabled && !widget.isLoading) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: (widget.isDisabled || widget.isLoading)
            ? null
            : () {
                HapticFeedback.mediumImpact();
                widget.onTap?.call();
              },
        child: Stack(
          children: [
            Container(
              width: widget.width,
              height: widget.height ?? 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border:
                    (widget.isOutlined && widget.isGradientBorder == true) ||
                            widget.gradientBorderColors != null
                        ? GradientBoxBorder(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: widget.gradientBorderColors ??
                                  AppColors.glassBorderGradient,
                            ),
                            width: 1,
                          )
                        : widget.borderColor != null
                            ? Border.all(color: widget.borderColor!, width: 1)
                            : null,
                gradient: !widget.isOutlined && widget.backgroundColor == null
                    ? LinearGradient(
                        colors:
                            widget.gradientColors ?? AppColors.colorGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: widget.backgroundColor != null
                    ? (widget.isDisabled
                        ? widget.backgroundColor?.withOpacity(0.5)
                        : widget.backgroundColor)
                    : null,
              ),
              child: Center(
                child: widget.isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.loaderColor ?? Colors.black,
                          ),
                        ),
                      )
                    : Padding(
                        padding: widget.padding ?? EdgeInsets.zero,
                        child: widget.child ??
                            (widget.text != null
                                ? Padding(
                                    padding: widget.padding ??
                                        const EdgeInsets.symmetric(
                                          horizontal: 16,
                                        ),
                                    child: Text(
                                      widget.text!,
                                      overflow: TextOverflow.ellipsis,
                                      style: style700S16.copyWith(
                                        color: widget.textColor ??
                                            AppColors.blackColor,
                                        fontSize: widget.fontSize,
                                      ),
                                    ),
                                  )
                                : const SizedBox()),
                      ),
              ),
            ),
            // Black overlay when disabled
            if (widget.isDisabled)
              Container(
                width: widget.width,
                height: widget.height ?? 46,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
