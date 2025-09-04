import 'package:ai_fashion/features/body-profile/screens/body_profile_screen.dart';
import 'package:ai_fashion/features/cart/screens/cart_screen.dart';
import 'package:ai_fashion/features/cart/screens/checkout_screen.dart';
import 'package:ai_fashion/features/chat/screens/chat_screen.dart';
import 'package:ai_fashion/features/chat/sub-features/brand_search/brand_search_screen.dart';
import 'package:ai_fashion/features/chat/sub-features/card-deck/card_deck_screen.dart';
import 'package:ai_fashion/features/edit-profile/screens/edit_profile_screen.dart';
import 'package:ai_fashion/features/home/screens/home_screen.dart';
import 'package:ai_fashion/features/liked/screens/liked_screen.dart';
import 'package:ai_fashion/features/login/screens/login_screen.dart';
import 'package:ai_fashion/features/my-designs/screens/my_designs_screen.dart';
import 'package:ai_fashion/features/orders-detail/screens/order_detail_screen.dart';
import 'package:ai_fashion/features/orders/screens/orders_screen.dart';
import 'package:ai_fashion/features/otp-verify/screens/otp_verify_screen.dart';
import 'package:ai_fashion/features/product-detail/product_detail_screen.dart';
import 'package:ai_fashion/features/quotations/screens/quotations_screen.dart';
import 'package:ai_fashion/features/saved-address/screens/saved_address_screen.dart';
import 'package:ai_fashion/features/signup/screens/signup_screen.dart';
import 'package:ai_fashion/features/skipped/screens/skipped_screen.dart';
import 'package:ai_fashion/features/splash/screens/splash_screen.dart';
import 'package:ai_fashion/features/welcome/screens/welcome_screen.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static final routes = [
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.splash,
      page: () => SplashScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.welcome,
      page: () => WelcomeScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.login,
      page: () => LoginScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.signup,
      page: () => SignupScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.otpVerify,
      page: () => OtpVerify(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.home,
      page: () => HomeScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.chat,
      page: () => ChatScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.cardDeck,
      page: () => CardDeckScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.productDetail,
      page: () => ProductDetailScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.liked,
      page: () => LikedScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.skipped,
      page: () => SkippedScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.myDesigns,
      page: () => MyDesignsScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.brandSearch,
      page: () => BrandSearchScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.quotations,
      page: () => QuotationsScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.orders,
      page: () => OrdersScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.orderDetail,
      page: () => OrderDetailScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.cart,
      page: () => CartScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.checkout,
      page: () => CheckoutScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.savedAddress,
      page: () => SavedAddressScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.bodyProfile,
      page: () => BodyProfileScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.editProfile,
      page: () => EditProfileScreen(),
    ),
  ];
}
