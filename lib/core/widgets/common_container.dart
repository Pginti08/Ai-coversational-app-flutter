import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:gradient_borders/gradient_borders.dart';
import 'package:vousvous/core/services/haptic_service.dart';

class CommonContainer extends StatelessWidget {
  final double? height;
  final double? width;
  final Widget? child;
  final EdgeInsets? padding;
  final List<Color>? gradientColors;
  final List<Color>? borderGradientColors;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderRadius;
  final bool enableBlur;
  final bool isCircle;
  final VoidCallback? onTap;
  final double blurStrength;
  final AlignmentGeometry? begin;
  final AlignmentGeometry? end;

  CommonContainer({
    Key? key,
    this.height,
    this.width,
    this.child,
    this.padding,
    this.gradientColors,
    this.borderGradientColors,
    this.backgroundColor,
    this.borderColor,
    this.borderRadius = 0,
    this.enableBlur = false,
    this.isCircle = false,
    this.onTap,
    this.blurStrength = 20.0,
    this.begin,
    this.end,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget containerWidget = Container(
      height: height,
      width: width,
      padding: padding,
      decoration: BoxDecoration(
        shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
        // Make background semi-transparent when blur is enabled
        color: backgroundColor,
        gradient: gradientColors != null
            ? LinearGradient(
                begin: begin ?? Alignment.topCenter,
                end: end ?? Alignment.bottomCenter,
                colors: gradientColors!)
            : null,
        borderRadius: isCircle ? null : BorderRadius.circular(borderRadius),
        border: borderGradientColors != null
            ? GradientBoxBorder(
                gradient: LinearGradient(
                  begin: begin ?? Alignment.topCenter,
                  end: end ?? Alignment.bottomCenter,
                  colors: borderGradientColors!,
                ),
              )
            : borderColor != null
                ? Border.all(color: borderColor!)
                : null,
      ),
      child: child,
    );

    Widget inkWellWidget = InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap != null
          ? () {
              HapticService.medium();
              onTap!();
            }
          : null,
      child: containerWidget,
    );

    if (enableBlur) {
      return ClipRRect(
        borderRadius:
            isCircle ? BorderRadius.zero : BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(
            sigmaX: blurStrength,
            sigmaY: blurStrength,
          ),
          child: inkWellWidget,
        ),
      );
    } else {
      return ClipRRect(
        borderRadius:
            isCircle ? BorderRadius.zero : BorderRadius.circular(borderRadius),
        child: inkWellWidget,
      );
    }
  }
}
