import 'package:ai_fashion/features/home/models/outfit_card_model.dart';

class ChatMessage {
  final String? type; // 'user' or 'ai'
  final String? message;
  final List<OutfitCardModel>? outfits;
  final DateTime? timestamp;

  ChatMessage({
    required this.type,
    required this.message,
    this.outfits,
    required this.timestamp,
  });

  // Factory constructor for user messages
  factory ChatMessage.user(
      {required String message, List<OutfitCardModel>? outfits}) {
    return ChatMessage(
      type: 'user',
      message: message,
      outfits: outfits,
      timestamp: DateTime.now(),
    );
  }

  // Factory constructor for AI messages
  factory ChatMessage.ai(
      {required String message, required List<OutfitCardModel> outfits}) {
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
