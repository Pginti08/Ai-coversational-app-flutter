import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/features/quotation-chat/models/quotation_chat_history_model.dart';
import 'package:vousvous/features/quotation-chat/widgets/final_quotation_card.dart';

class QuotationMessageTile extends StatefulWidget {
  const QuotationMessageTile({
    required this.message,
    super.key,
  });

  final Item message;

  @override
  State<QuotationMessageTile> createState() => _QuotationMessageTileState();
}

class _QuotationMessageTileState extends State<QuotationMessageTile>
    with AutomaticKeepAliveClientMixin {
  late Item currentMessage;

  @override
  void initState() {
    super.initState();
    currentMessage = widget.message;
  }

  void _updateMessage(Item updatedMessage) {
    setState(() {
      currentMessage = updatedMessage;
    });
  }

  bool get _isUserMessage => currentMessage.sender?.toLowerCase() == "user";

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final bool isImage = currentMessage.messageType == "image";
    final bool isCard = currentMessage.messageType == "card";

    return Align(
      alignment: _isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: isCard
              ? MediaQuery.sizeOf(context).width
              : MediaQuery.sizeOf(context).width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: _isUserMessage
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // 1. CARD MESSAGE TYPE
            if (isCard && isNotNullOrEmpty(currentMessage.cardDetail))
              FinalQuotationCard(
                quotation: currentMessage.cardDetail ?? CardDetail(),
                updatedBySupport:
                    currentMessage.updatedBySupport ?? UpdatedBySupport(),
                message: currentMessage,
                onMessageUpdate: _updateMessage,
              )

            // 2. IMAGE MESSAGE TYPE (Text attached with image)
            else if (isImage)
              Container(
                padding:
                    const EdgeInsets.all(4), // Small frame padding around image
                decoration: BoxDecoration(
                  color: _isUserMessage
                      ? const Color(0xFF181818)
                      : const Color(0xFF313131),
                  borderRadius: _isUserMessage
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The Image Section
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: AspectRatio(
                        aspectRatio: 0.75,
                        child: AppNetworkImage(
                          imageUrl: currentMessage.imageUrl ?? "",
                          fit: BoxFit.cover,
                          backgroundColor: Colors.grey.shade900,
                          isOpenImageViewer: true,
                        ),
                      ),
                    ),

                    // The Text Section (Caption)
                    if (isNotNullOrEmpty(currentMessage.message) &&
                        currentMessage.message?.toLowerCase() != "image")
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
                        child: SelectionArea(
                          child: GptMarkdown(
                            currentMessage.message ?? "",
                            style: style400S16.copyWith(
                              letterSpacing: 0.32,
                              fontSize: 14, // Slightly smaller font for caption
                            ),
                            onLinkTap: (url, title) {
                              launchUrl(Uri.parse(url),
                                  mode: LaunchMode.externalApplication);
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              )

            // 3. STANDARD TEXT MESSAGE TYPE
            else
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: _isUserMessage
                      ? const Color(0xFF181818)
                      : const Color(0xFF313131),
                  borderRadius: _isUserMessage
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomLeft: Radius.circular(20),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20),
                        ),
                ),
                child: SelectionArea(
                  child: GptMarkdown(
                    currentMessage.message ?? "",
                    style: style400S16.copyWith(letterSpacing: 0.32),
                    onLinkTap: (url, title) {
                      launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
                ),
              ),

            // TIMESTAMP (Common for all types)
            if (isNotNullOrEmpty(currentMessage.createdAt)) ...[
              hSizedBox4,
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  DateFormat('hh:mm a')
                      .format(currentMessage.createdAt!.toLocal()),
                  style: style400S10.copyWith(
                    fontSize: 8,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
