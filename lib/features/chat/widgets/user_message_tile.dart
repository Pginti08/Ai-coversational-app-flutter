import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/image_viewer_screen.dart';
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
    // Combine both lists safely
    final List<String> displayImages = [
      ...(message.refImage ?? []),
      ...(message.images?.map((e) => e.filename ?? "") ?? []),
    ].where((e) => isNotNullOrEmpty(e)).toList().cast<String>();

    final double avatarSize = 80.0;
    final double overlap = 65.0;
    final double totalWidth = displayImages.isNotEmpty
        ? (displayImages.length * (avatarSize - overlap)) + overlap
        : 0;

    return SwipeToReply(
      onReply: () {
        if (displayImages.isNotEmpty) {
          chatController.userSelectedRemixOutfits.clear();
          // For reply, we might just want to use the first available images or handle mixed types differently
          // But based on current logic, just adding them to selected outfits seems to be the intent
          chatController.userSelectedRemixOutfits.value = displayImages;
          chatController.typeFocusNode.requestFocus();
        }
      },
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (displayImages.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.to(
                        ImageViewerScreen(
                          imageUrls: displayImages.toList().obs,
                        ),
                        opaque: false,
                        transition: Transition.fadeIn,
                        fullscreenDialog: true,
                      );
                    },
                    child: SizedBox(
                      height: avatarSize,
                      width: totalWidth,
                      child: Stack(
                        children: List.generate(displayImages.length, (index) {
                          return Positioned(
                            left: index * (avatarSize - overlap),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.primaryColor,
                                    width: 1.5,
                                    strokeAlign: BorderSide.strokeAlignOutside),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: AppNetworkImage(
                                width: avatarSize,
                                height: avatarSize,
                                imageUrl: displayImages[index],
                                borderRadius: BorderRadius.circular(8),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ],
              ),
              hSizedBox8,
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
