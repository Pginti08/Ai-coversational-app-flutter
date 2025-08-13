import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:flutter/material.dart';

class AiTypingTile extends StatelessWidget {
  const AiTypingTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              AssetConstants.star,
              width: 28,
            ),
            hSizedBox10,
            Text("Finding curated dresses for you...",
                style: style400S16.copyWith(letterSpacing: 0.32)),
          ],
        ),
      ),
    );
  }
}
