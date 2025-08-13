// api_constants.dart
import 'package:ai_fashion/core/constants/flavors.dart';

class ApiConstants {
  static String authURL = Flavor.getFlavor == FlavorType.development
      ? 'https://devallyraauth.pansophictech.com'
      : Flavor.getFlavor == FlavorType.staging
          ? 'https://authstage.allyra.ai'
          : Flavor.getFlavor == FlavorType.demo
              ? 'https://demoauth.allyra.ai'
              : Flavor.getFlavor == FlavorType.production
                  ? 'https://auth.allyra.ai'
                  : '';

  static String forgeURL = Flavor.getFlavor == FlavorType.development
      ? 'https://devallyraforge.pansophictech.com'
      : Flavor.getFlavor == FlavorType.staging
          ? 'https://forgestage.allyra.ai'
          : Flavor.getFlavor == FlavorType.demo
              ? 'https://demoforge.allyra.ai'
              : Flavor.getFlavor == FlavorType.production
                  ? 'https://forge.allyra.ai'
                  : '';

  static String lyceumURL = Flavor.getFlavor == FlavorType.development
      ? 'https://devallyralyceum.pansophictech.com'
      : Flavor.getFlavor == FlavorType.staging
          ? 'https://lyceumstage.allyra.ai'
          : Flavor.getFlavor == FlavorType.demo
              ? 'https://demolyceum.allyra.ai'
              : Flavor.getFlavor == FlavorType.production
                  ? 'https://lyceum.allyra.ai'
                  : '';

  static String chatURL = Flavor.getFlavor == FlavorType.development
      ? 'https://devallyrachat.pansophictech.com'
      : Flavor.getFlavor == FlavorType.staging
          ? 'https://stagechat.allyra.ai'
          : Flavor.getFlavor == FlavorType.demo
              ? 'https://demochat.allyra.ai'
              : Flavor.getFlavor == FlavorType.production
                  ? 'https://chat.allyra.ai'
                  : '';

  static String socketChatURL = Flavor.getFlavor == FlavorType.development
      ? 'wss://devallyrachat.pansophictech.com/ws/chat/'
      : Flavor.getFlavor == FlavorType.staging
          ? 'wss://stagechat.allyra.ai/ws/chat/'
          : Flavor.getFlavor == FlavorType.demo
              ? 'wss://demochat.allyra.ai/ws/chat/'
              : Flavor.getFlavor == FlavorType.production
                  ? 'wss://chat.allyra.ai/ws/chat/'
                  : '';

  // Auth endpoints
  static const String loginUser = '/auth/login-initiate';
  static const String verifyOtp = '/auth/verify-otp';
  static const String registerUser = '/auth/signup';
  static const String forgotPassword = '/auth/api/forget-password-email-otp';
  static const String verifyForgetOtp = '/auth/api/verify-forget-otp';
  static const String resetPassword = '/auth/api/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String getUserDetail = '/auth/user';
  static const String profileUpdate = '/auth/update-profile';
  static const String getAssignedAgentsList =
      '/auth/trainer/assigned-allyroids';
  static const String getLyceumAgentsDetails = '/agent_card';
  static const String newConversation = '/conversation';
  static const String conversationList = '/user_conversations';
  static const String chatToken = '/token';
  static const String getInteraction = '/trainer/interaction';
  static const String getSummaryInteraction = '/trainer/interaction/summary';
  static const String chatInjection = '/trainer/chat_injection';
  static const String chatHistoryTrainer = '/trainer/chat/';
  static const String giveFeedback = '/trainer/conversation/feedback';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
