import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:flutter/material.dart';

class ChatActionsButtons extends StatelessWidget {
  const ChatActionsButtons({
    super.key,
    required this.options,
    required this.onOptionTap,
  });

  final List<Option> options;
  final void Function(Option message) onOptionTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8, // horizontal gap between buttons
      runSpacing: 8, // vertical gap between lines
      children: options.map((option) {
        return SizedBox(
          height: 48,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppButton(
                padding: EdgeInsets.symmetric(horizontal: 10),
                onTap: () => onOptionTap(option),
                isGradientBorder: true,
                isOutlined: true,
                text: option.text ?? "",
                textColor: AppColors.whiteColor,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class Option {
  String? text;
  String? type;
  String? value;
  String? actionType;

  Option({
    this.text,
    this.type,
    this.value,
    this.actionType,
  });

  factory Option.fromJson(Map<String, dynamic> json) => Option(
        text: json["text"],
        type: json["type"],
        value: json["value"],
        actionType: json["action_type"],
      );

  Map<String, dynamic> toJson() => {
        "text": text,
        "type": type,
        "value": value,
        "action_type": actionType,
      };
}
