import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gradient_borders/box_borders/gradient_box_border.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.errorText,
    this.hasError = false,
    this.isRequired = false,
    this.obscureText = false,
    this.enabled = true,
    this.isGradientBorder = false,
    this.readOnly = false,
    this.autofocus = false,
    this.controller,
    this.onChanged,
    this.onTap,
    this.keyboardType,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.inputFormatters,
    this.textInputAction,
    this.focusNode,
    this.validator,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.fillColor,
    this.borderColor,
    this.borderRadius = 16,
    this.contentPadding,
    this.outsideMargin,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.textAlign = TextAlign.start,
    this.expands = false,
    this.scrollController,
  });
  final String? label;
  final String? hint;
  final String? errorText;
  final bool hasError;
  final bool isRequired;
  final bool obscureText;
  final bool enabled;
  final bool isGradientBorder;
  final bool readOnly;
  final bool autofocus;
  final TextEditingController? controller;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final TextInputType? keyboardType;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;
  final TextCapitalization textCapitalization;
  final Color? fillColor;
  final Color? borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? outsideMargin;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final TextAlign textAlign;
  final bool expands;
  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: outsideMargin ??
                const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: isGradientBorder
                ? BoxDecoration(
                    border: GradientBoxBorder(
                      width: 1,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: AppColors.glassBorderGradient,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(borderRadius),
                    color: enabled
                        ? (fillColor ?? Colors.transparent)
                        : (AppColors.greyColor.withOpacity(0.1)),
                  )
                : ShapeDecoration(
                    color: enabled
                        ? (fillColor ?? Colors.transparent)
                        : (AppColors.greyColor.withOpacity(0.1)),
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        width: 1,
                        color: borderColor ?? Color(0xFF3D3D3D),
                      ),
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (label != null) ...[
                  Row(
                    children: [
                      Text(
                        label!,
                        style: labelStyle ??
                            style700S12.copyWith(
                              color: Color(0xFF666666),
                              letterSpacing: 0.96,
                            ),
                      ),
                      if (isRequired)
                        Text(
                          ' *',
                          style: labelStyle ??
                              style700S12.copyWith(
                                color: AppColors.redColor,
                                letterSpacing: 0.96,
                              ),
                        ),
                    ],
                  ),
                  hSizedBox4,
                ],
                Row(
                  children: [
                    if (prefixIcon != null) ...[
                      prefixIcon!,
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: TextFormField(
                        autofocus: autofocus,
                        controller: controller,
                        focusNode: focusNode,
                        onChanged: onChanged,
                        onTap: onTap,
                        readOnly: readOnly,
                        enabled: enabled,
                        expands: expands,
                        obscureText: obscureText,
                        keyboardType: keyboardType,
                        maxLines: maxLines,
                        minLines: minLines,
                        maxLength: maxLength,
                        textAlign: textAlign,
                        textInputAction: textInputAction,
                        textCapitalization: textCapitalization,
                        inputFormatters: inputFormatters,
                        validator: validator,
                        onFieldSubmitted: onSubmitted,
                        cursorColor: AppColors.whiteTextColor,
                        cursorHeight: 18,
                        scrollController: scrollController,
                        style: textStyle ??
                            style400S16.copyWith(
                              color: AppColors.whiteColor,
                              letterSpacing: 0.32,
                            ),
                        decoration: InputDecoration(
                          hintText: hint,
                          counterText: '',
                          hintStyle: hintStyle ??
                              style400S16.copyWith(
                                color: AppColors.greyTextColor,
                                letterSpacing: 0.32,
                              ),
                          isDense: true,
                          filled: false,
                          contentPadding: contentPadding ?? EdgeInsets.zero,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    if (suffixIcon != null) ...[
                      const SizedBox(width: 8),
                      suffixIcon!,
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isNotNullOrEmpty(errorText))
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 16),
              child: Text(
                errorText!,
                style: style300S12.copyWith(color: AppColors.redColor),
              ),
            ),
        ],
      ),
    );
  }
}
