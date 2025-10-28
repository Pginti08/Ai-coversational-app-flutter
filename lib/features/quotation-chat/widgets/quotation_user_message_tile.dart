import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/features/quotation-chat/models/quotation_chat_history_model.dart';
import 'package:flutter/material.dart';

class QuotationUserMessageTile extends StatelessWidget {
  const QuotationUserMessageTile({required this.message, super.key});

  final Message message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
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
                      isJson(message.message)
                          ? jsonToReadableText(message.message ?? "")
                          : (message.message ?? ""),
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
