import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';
import 'package:pinput/pinput.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';

class AppPinputField extends StatefulWidget {
  const AppPinputField({
    required this.length,
    super.key,
    this.controller,
    this.size,
    this.onCompleted,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.inputFormatters = const [],
    this.errorText,
    this.autofocus = true,
    this.showCursor = true,
    this.isCursorAnimationEnabled = true,
    this.mainAxisAlignment = MainAxisAlignment.spaceEvenly,
  });

  final int length;
  final double? size;
  final TextEditingController? controller;
  final void Function(String)? onCompleted;
  final void Function(String)? onChanged;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final bool autofocus;
  final bool showCursor;
  final bool isCursorAnimationEnabled;
  final MainAxisAlignment mainAxisAlignment;
  final String? errorText;

  @override
  _AppPinputFieldState createState() => _AppPinputFieldState();
}

class _AppPinputFieldState extends State<AppPinputField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNode);
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  PinTheme _buildPinTheme({Color? fillColor, List<Color>? gradientColors}) {
    return PinTheme(
      width: widget.size ?? 50,
      height: widget.size ?? 50,
      textStyle: style500S20,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(14),
        border: GradientBoxBorder(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors ?? AppColors.glassBorderGradient,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final baseTheme = _buildPinTheme();
    final focusedTheme = _buildPinTheme(
      gradientColors: [AppColors.whiteColor, AppColors.whiteColor],
    );
    final errorTheme = _buildPinTheme(
      gradientColors: [AppColors.redColor, AppColors.redColor],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RepaintBoundary(
          child: Pinput(
            key: ValueKey(
                '${widget.errorText != null}'), // Force rebuild on state change
            mainAxisAlignment: widget.mainAxisAlignment,
            autofocus: widget.autofocus,
            showCursor: widget.showCursor,
            isCursorAnimationEnabled: widget.isCursorAnimationEnabled,
            length: widget.length,
            controller: widget.controller,
            focusNode: _focusNode,
            closeKeyboardWhenCompleted: false,
            onCompleted: widget.onCompleted,
            onChanged: widget.onChanged,
            defaultPinTheme: baseTheme,
            submittedPinTheme: baseTheme,
            focusedPinTheme: focusedTheme,
            errorPinTheme: errorTheme,
            disabledPinTheme: baseTheme,
            followingPinTheme: baseTheme,
            keyboardType: widget.keyboardType,
            inputFormatters: widget.inputFormatters,
            forceErrorState: widget.errorText != null,
            // Disable animations to prevent border interpolation issues
            animationDuration: Duration.zero,
            animationCurve: Curves.linear,
          ),
        ),
        if (widget.errorText != null)
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                widget.errorText!,
                style: style400S12.copyWith(color: AppColors.redColor),
              ),
            ),
          ),
      ],
    );
  }
}
