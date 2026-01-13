// api_constants.dart
import 'package:vousvous/core/constants/flavors.dart';

class ApiConstants {
  static String baseURL = Flavor.getFlavor == FlavorType.development
      ? 'https://devapi.vousvous.com'
      : Flavor.getFlavor == FlavorType.staging
          ? 'http://13.235.114.164:3000'
          : Flavor.getFlavor == FlavorType.demo
              ? 'http://13.235.114.164:3000'
              : Flavor.getFlavor == FlavorType.production
                  ? 'https://api.vousvous.com'
                  : '';
  static String chatURL = Flavor.getFlavor == FlavorType.development
      ? 'https://devai.vousvous.com'
      : Flavor.getFlavor == FlavorType.staging
          ? 'http://34.233.54.141:8000'
          : Flavor.getFlavor == FlavorType.demo
              ? 'http://34.233.54.141:8000'
              : Flavor.getFlavor == FlavorType.production
                  ? 'https://aiservices.vousvous.com'
                  : '';

  static String imageURL = Flavor.getFlavor == FlavorType.development
      ? 'https://devai.vousvous.com/uploads/'
      : Flavor.getFlavor == FlavorType.staging
          ? 'http://34.233.54.141:8000/uploads/'
          : Flavor.getFlavor == FlavorType.demo
              ? 'http://34.233.54.141:8000/uploads/'
              : Flavor.getFlavor == FlavorType.production
                  ? 'https://aiservices.vousvous.com/uploads/'
                  : '';

  // Auth endpoints
  static const String signIn = '/auth/send-otp/sign-in';
  static const String signUp = '/auth/send-otp/sign-up';
  static const String verifyOtp = '/auth/verify-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String refreshToken = '/auth/refresh-token';
  static const String getUserDetail = '/user/me';
  static const String updateProfileDetail = '/user/profile';
  static const String updateProfileImage = '/user/profile-image';
  static const String getSuggestedProducts = '/product/suggestions';
  static const String getLikedProducts = '/product/likes';
  static const String getSkipProducts = '/product/skips';
  static const String addresses = '/user/addresses';
  static const String bodyProfiles = '/user/body-profiles';
  static const String getSessionList = '/sessions';
  static const String getBrandList = '/product/brands';
  static const String uploadImage = '/upload/';
  static const String quotations = '/quotations';
  static const String quotationsStream = '/quotations/stream';
  static const String analyzeDress = '/quotations/analyze-dress';
  static const String bodyMeasurementsAnalyze = '/body-measurements/analyze';
  static const String cart = '/cart';
  static const String modificationRequest = '/modification-request';
  static const String inviteFriend = '/user/invite-friend';
  static const String orders = '/orders';
  static const String ordersStream = '/orders/stream';
  static const String invoice = '/invoice';
  static const String guideSeen = '/user/guide-seen';
  static const String fcmToken = '/user/fcm-token';
  static const String product = '/product';
  static const String otherProduct = '/product/user';
  static const String getUserProfile = '/user/profile';
  static const String analyzeProduct = '/products/ai-analysis';
  static const String follow = '/follow';
  static const String unfollow = '/unfollow';
  static const String checkQuotationExists = '/quotations/check-exists';
  static const String createQuotation = '/quotations/create-with-bp';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}
