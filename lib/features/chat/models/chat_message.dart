import 'package:ai_fashion/features/home/models/product_list_model.dart';

class ChatMessage {
  final String? type; // 'user' or 'ai'
  final String? message;
  final List<Product>? outfits;
  final DateTime? timestamp;

  ChatMessage({
    required this.type,
    required this.message,
    this.outfits,
    required this.timestamp,
  });

  // Factory constructor for user messages
  factory ChatMessage.user({required String message, List<Product>? outfits}) {
    return ChatMessage(
      type: 'user',
      message: message,
      outfits: outfits,
      timestamp: DateTime.now(),
    );
  }

  // Factory constructor for AI messages
  factory ChatMessage.ai(
      {required String message, required List<Product> outfits}) {
    return ChatMessage(
      type: 'ai',
      message: message,
      outfits: outfits,
      timestamp: DateTime.now(),
    );
  }

  // Check if message is from user
  bool get isUser => type == 'user';

  // Check if message is from AI
  bool get isAi => type == 'ai';
}
