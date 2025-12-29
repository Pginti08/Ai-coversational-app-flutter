import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/stacked_card_widget.dart';
import 'package:vousvous/features/chat/controller/chat_controller.dart';
import 'package:vousvous/features/chat/models/chat_history_model.dart';
import 'package:vousvous/routes/app_pages.dart';

class AiMessageTile extends StatefulWidget {
  const AiMessageTile({
    required this.message,
    required this.chatController,
    super.key,
  });

  final Message message;
  final ChatController chatController;

  @override
  State<AiMessageTile> createState() => _AiMessageTileState();
}

class _AiMessageTileState extends State<AiMessageTile> {
  @override
  Widget build(BuildContext context) {
    final hasOutfits =
        widget.message.images != null && widget.message.images!.isNotEmpty;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.9,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SvgPicture.asset(
              AssetConstants.sparkle,
              width: 20,
            ),
            hSizedBox10,

            // CASE 1: No outfits → just message
            if (!hasOutfits)
              SelectionArea(
                child: GptMarkdown(
                  widget.message.message ?? "",
                  style: style400S16.copyWith(letterSpacing: 0.32),
                  onLinkTap: (url, title) {
                    launchUrl(Uri.parse(url),
                        mode: LaunchMode.externalApplication);
                  },
                ),
              ),

            // CASE 2: Exactly 1 outfit → image + message
            if (hasOutfits && widget.message.images!.length == 1) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AppNetworkImage(
                      imageUrl:
                          "${widget.message.images!.first.filename ?? ""}",
                      borderRadius: BorderRadius.circular(12),
                      fit: BoxFit.cover,
                      width: 210,
                      height: 315,
                      onTap: () {
                        Get.toNamed(Routes.remixedProduct, arguments: {
                          "imageUrl":
                              "${widget.message.images!.first.filename ?? ""}"
                        });
                      },
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: AppButton(
                      height: 36,
                      width: 36,
                      onTap: () {
                        widget.chatController.userSelectedRemixOutfits.clear();
                        widget.chatController.userSelectedRemixOutfits.value = [
                          "${widget.message.images!.first.filename ?? ""}"
                        ];
                        widget.chatController.typeFocusNode.requestFocus();
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AssetConstants.magicpen,
                              color: AppColors.whiteColor,
                              width: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
              hSizedBox10,
              GptMarkdown(
                widget.message.message ?? "",
                style: style400S16.copyWith(letterSpacing: 0.32),
                onLinkTap: (url, title) {
                  launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                },
              ),
            ],

            // CASE 3: Multiple outfits → message + card deck
            if (hasOutfits && widget.message.images!.length > 1) ...[
              GptMarkdown(
                widget.message.message ?? "",
                style: style400S16.copyWith(letterSpacing: 0.32),
                onLinkTap: (url, title) {
                  launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                },
              ),
              hSizedBox30,
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.cardDeck, arguments: {
                      "outfits": widget.message.images
                          ?.map((e) => e.filename ?? "")
                          .toList()
                    });
                  },
                  child: Container(
                    width: 200.w,
                    height: 320.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.colorGradient[0].withAlpha(50),
                          blurRadius: 50,
                          spreadRadius: 5,
                          offset: const Offset(-20, 0),
                        ),
                        BoxShadow(
                          color: AppColors.colorGradient[1].withAlpha(50),
                          blurRadius: 50,
                          spreadRadius: 5,
                          offset: const Offset(20, 0),
                        ),
                      ],
                    ),
                    child: CardDeckWidget<String>(
                      items: widget.message.images!
                          .map((e) => e.filename ?? "")
                          .toList()
                          .obs,
                      itemBuilder: (imageUrl) => ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AppNetworkImage(
                          imageUrl: "$imageUrl",
                          borderRadius: BorderRadius.circular(14),
                          fit: BoxFit.cover,
                          width: 190.w,
                          height: 310.h,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              hSizedBox30,
            ],
          ],
        ),
      ),
    );
  }
}
