import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:flutter/material.dart';

class BulletPointList extends StatelessWidget {
  final List<String> items;
  final TextStyle? style;

  BulletPointList({super.key, required this.items, this.style});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                hSizedBox8,
                Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFCCCCCC),
                    )),
              ],
            ),
            wSizedBox10,
            Expanded(
              child: Text(item,
                  style: style ??
                      style400S16.copyWith(
                        letterSpacing: 0.32,
                        color: Color(0xFFCCCCCC),
                      )),
            ),
          ],
        );
      }).toList(),
    );
  }
}
