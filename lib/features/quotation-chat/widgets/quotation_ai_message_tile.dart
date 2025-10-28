import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/features/quotation-chat/models/final_quotation_model.dart';
import 'package:ai_fashion/features/quotation-chat/models/quotation_chat_history_model.dart';
import 'package:ai_fashion/features/quotation-chat/widgets/final_quotation_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:intl/intl.dart';
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
            (widget.message.messageType == "card" &&
                    widget.message.message == "quotation_card" &&
                    isNotNullOrEmpty(widget.message.cardDetail))
                ? FinalQuotationCard(
                    quotation: FinalQuotationModel(
                    quotationNumber: widget.message.cardDetail?.quotationNumber,
                    dressImageUrl: widget.message.cardDetail?.dressImageUrl,
                    date: DateFormat("MMMM dd, yyyy")
                        .format(widget.message.cardDetail!.date!),
                    color: widget.message.cardDetail?.color,
                    material: widget.message.cardDetail?.material,
                    type: widget.message.cardDetail?.purchaseType,
                    measurements: widget.message.cardDetail?.sizeMeasurement ??
                        widget.message.cardDetail?.bulkQuantities.toString(),
                    specialRequests: widget.message.cardDetail?.specialRequests,
                    quantity: widget.message.cardDetail?.quantity,
                    price:
                        "${AssetConstants.rupeeSymbol}${widget.message.cardDetail?.price.toString()}/pc",
                    status: widget.message.cardDetail?.status,
                    quotationId: widget.message.quotationId,
                  ))
                : GptMarkdown(
                    widget.message.message ?? "",
                    style: style400S16.copyWith(letterSpacing: 0.32),
                    onLinkTab: (url, title) {
                      launchUrl(Uri.parse(url),
                          mode: LaunchMode.externalApplication);
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
