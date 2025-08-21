import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CustomRadio<T> extends StatefulWidget {
  final T value;
  final T groupValue;
  final Widget? titleWidget;
  final void Function(T) onChanged;
  final double size;

  const CustomRadio({
    super.key,
    required this.value,
    this.titleWidget,
    required this.groupValue,
    required this.onChanged,
    this.size = 18,
  });

  @override
  State<CustomRadio<T>> createState() => _CustomRadioState<T>();
}

class _CustomRadioState<T> extends State<CustomRadio<T>> {
  @override
  Widget build(BuildContext context) {
    bool selected = (widget.value == widget.groupValue);

    return GestureDetector(
      onTap: () {
        widget.onChanged(widget.value);
      },
      child: Container(
        color: Colors.transparent,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              hSizedBox8,
              selected
                  ? SvgPicture.asset(
                      AssetConstants.tickCircle,
                      height: widget.size,
                      width: widget.size,
                    )
                  : Container(
                      height: widget.size,
                      width: widget.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.lightGreyTextColor.withAlpha(150),
                        ),
                      ),
                    ),
            ]),
            if (widget.titleWidget != null) ...[
              const SizedBox(width: 12),
              Expanded(child: widget.titleWidget!),
            ],
          ],
        ),
      ),
    );
  }
}
