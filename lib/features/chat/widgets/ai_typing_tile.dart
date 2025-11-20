import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';

class AiTypingTile extends StatelessWidget {
  const AiTypingTile({required this.message, super.key});
  final Rx<String?> message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.9,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              AssetConstants.star,
              width: 28,
            ),
            hSizedBox10,
            Obx(() => Text(message.value ?? "AI is thinking...",
                style: style400S16.copyWith(letterSpacing: 0.32))),
          ],
        ),
      ),
    );
  }
}
