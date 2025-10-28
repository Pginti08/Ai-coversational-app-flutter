import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/stacked_card_widget.dart';
import 'package:ai_fashion/features/chat/models/chat_history_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UserMessageTile extends StatelessWidget {
  const UserMessageTile({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    final refImages = (message.refImage ?? []);

    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (isNotNullOrEmpty(message.refImage)) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CardDeckWidget(
                  maxCards: 4,
                  items: refImages.toList().obs,
                  itemBuilder: (imageUrl) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppNetworkImage(
                      imageUrl: "$imageUrl",
                      borderRadius: BorderRadius.circular(8),
                      fit: BoxFit.cover,
                      width: 80,
                      height: 80,
                      isOpenImageViewer: true,
                    ),
                  ),
                ),
              ],
            ),
            hSizedBox12,
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.8,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xFF222222),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: Radius.circular(20),
                      ),
                    ),
                    child: Text(
                      message.message ?? "",
                      style: style400S16.copyWith(letterSpacing: 0.32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
