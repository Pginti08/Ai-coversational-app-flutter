import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/stacked_card_widget.dart';
import 'package:ai_fashion/features/home/models/product_list_model.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class AiMessageTile extends StatefulWidget {
  AiMessageTile({
    required this.message,
    this.outfits,
    super.key,
  });

  final String message;
  final List<Product>? outfits;

  @override
  State<AiMessageTile> createState() => _AiMessageTileState();
}

class _AiMessageTileState extends State<AiMessageTile> {
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
            SvgPicture.asset(
              AssetConstants.sparkle,
              width: 20,
            ),
            hSizedBox10,
            if (isNotNullOrEmpty(widget.outfits) &&
                widget.outfits?.length == 1) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AppNetworkImage(
                  imageUrl: widget.outfits?.first.image ?? "",
                  borderRadius: BorderRadius.circular(8),
                  fit: BoxFit.cover,
                  width: 210,
                  height: 315,
                ),
              ),
              hSizedBox10,
              GptMarkdown(
                widget.message,
                style: style400S16.copyWith(letterSpacing: 0.32),
                onLinkTab: (url, title) {
                  launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                },
              ),
            ] else if (isNotNullOrEmpty(widget.outfits)) ...[
              GptMarkdown(
                widget.message,
                style: style400S16.copyWith(letterSpacing: 0.32),
                onLinkTab: (url, title) {
                  launchUrl(Uri.parse(url),
                      mode: LaunchMode.externalApplication);
                },
              ),
              hSizedBox30,
              // The main change is here. We wrap the cards in a Container
              // with a multi-layered boxShadow to create the glow effect.
              Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () {
                    Get.toNamed(Routes.cardDeck,
                        arguments: {"outfits": widget.outfits});
                  },
                  child: Container(
                    width: 200.w,
                    height: 320.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        // First shadow layer, using the first color of your gradient
                        BoxShadow(
                          color: AppColors.colorGradient[0].withAlpha(50),
                          blurRadius: 50,
                          spreadRadius: 5,
                          offset: const Offset(-20, 0),
                        ),
                        // Second shadow layer, using the second color of your gradient
                        BoxShadow(
                          color: AppColors.colorGradient[1].withAlpha(50),
                          blurRadius: 50,
                          spreadRadius: 5,
                          offset: const Offset(20, 0),
                        ),
                      ],
                    ),
                    child: CardDeckWidget<String>(
                      items: widget.outfits!
                          .map((e) => e.image ?? '')
                          .toList()
                          .obs,
                      itemBuilder: (imageUrl) => ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: AppNetworkImage(
                          imageUrl: imageUrl,
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
