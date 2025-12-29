import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/features/quotation-chat/models/quotation_chat_history_model.dart';
import 'package:vousvous/features/quotation-chat/widgets/final_quotation_card.dart';

class QuotationAiMessageTile extends StatefulWidget {
  const QuotationAiMessageTile({
    required this.message,
    super.key,
  });

  final Message message;

  @override
  State<QuotationAiMessageTile> createState() => _QuotationAiMessageTileState();
}

class _QuotationAiMessageTileState extends State<QuotationAiMessageTile>
    with AutomaticKeepAliveClientMixin {
  late Message currentMessage;

  @override
  void initState() {
    super.initState();
    currentMessage = widget.message;
  }

  void _updateMessage(Message updatedMessage) {
    setState(() {
      currentMessage = updatedMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            (currentMessage.messageType == "card" &&
                    currentMessage.message == "quotation_card" &&
                    isNotNullOrEmpty(currentMessage.cardDetail))
                ? FinalQuotationCard(
                    quotation: currentMessage.cardDetail ?? CardDetail(),
                    updatedBySupport:
                        currentMessage.updatedBySupport ?? CardDetail(),
                    message: currentMessage,
                    onMessageUpdate: _updateMessage,
                  )
                : currentMessage.messageType == "image"
                    ? Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width *
                              0.65, // 65% width max
                          minWidth: 200,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(30),
                              blurRadius: 10,
                              spreadRadius: 1,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              // Product Image filling the container
                              AspectRatio(
                                aspectRatio:
                                    0.75, // Portrait ratio to show full dress
                                child: AppNetworkImage(
                                  imageUrl: currentMessage.message ?? "",
                                  fit: BoxFit
                                      .cover, // Cover to fill container completely
                                  backgroundColor: Colors.grey.shade900,
                                  isOpenImageViewer: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : SelectionArea(
                        child: GptMarkdown(
                          currentMessage.message ?? "",
                          style: style400S16.copyWith(letterSpacing: 0.32),
                          onLinkTab: (url, title) {
                            launchUrl(Uri.parse(url),
                                mode: LaunchMode.externalApplication);
                          },
                        ),
                      ),
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
