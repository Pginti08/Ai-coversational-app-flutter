import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/image_viewer_screen.dart';
import 'package:vousvous/core/widgets/stacked_card_widget.dart';
import 'package:vousvous/core/widgets/swipe_to_reply.dart';
import 'package:vousvous/features/chat/controller/chat_controller.dart';
import 'package:vousvous/features/chat/models/chat_history_model.dart';

class UserMessageTile extends StatelessWidget {
  const UserMessageTile(
      {required this.message, required this.chatController, super.key});

  final Message message;
  final ChatController chatController;

  @override
  Widget build(BuildContext context) {
    final refImages = (message.refImage ?? []);

    return SwipeToReply(
      onReply: () {
        if (isNotNullOrEmpty(message.refImage)) {
          chatController.userSelectedRemixOutfits.clear();
          chatController.userSelectedRemixOutfits.value =
              message.refImage!.toList();
          chatController.typeFocusNode.requestFocus();
        }
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isNotNullOrEmpty(message.refImage)) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        ImageViewerScreen(
                          imageUrls: refImages.toList().obs,
                        ),
                        opaque: false,
                        transition: Transition.fadeIn,
                        fullscreenDialog: true,
                      );
                    },
                    child: CardDeckWidget(
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
                        ),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: const BoxDecoration(
                        color: Color(0xFF222222),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        ),
                      ),
                      child: SelectionArea(
                        child: Text(
                          message.message ?? "",
                          style: style400S16.copyWith(letterSpacing: 0.32),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
