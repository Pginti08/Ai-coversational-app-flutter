import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/features/quotation-chat/models/quotation_chat_history_model.dart';
import 'package:ai_fashion/features/quotation-chat/widgets/final_quotation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class QuotationAiMessageTile extends StatefulWidget {
  const QuotationAiMessageTile({
    required this.message,
    super.key,
  });

  final Message message;

  @override
  State<QuotationAiMessageTile> createState() => _QuotationAiMessageTileState();
}

class _QuotationAiMessageTileState extends State<QuotationAiMessageTile> {
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
}
