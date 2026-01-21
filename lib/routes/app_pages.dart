import 'package:get/get.dart';
import 'package:vousvous/features/body-profile/screens/body_profile_screen.dart';
import 'package:vousvous/features/cart/screens/cart_screen.dart';
import 'package:vousvous/features/chat/screens/chat_screen.dart';
import 'package:vousvous/features/chat/sub-features/brand_search/brand_search_screen.dart';
import 'package:vousvous/features/chat/sub-features/card-deck/card_deck_screen.dart';
import 'package:vousvous/features/chat/sub-features/remixed-product/screens/remixed_product_screen.dart';
import 'package:vousvous/features/checkout/screens/checkout_screen.dart';
import 'package:vousvous/features/edit-profile/screens/edit_profile_screen.dart';
import 'package:vousvous/features/home/screens/home_screen.dart';
import 'package:vousvous/features/invite-friend/screens/invite_friend_screen.dart';
import 'package:vousvous/features/liked/liked-product/liked_product_screen.dart';
import 'package:vousvous/features/liked/screens/liked_screen.dart';
import 'package:vousvous/features/login/screens/login_screen.dart';
import 'package:vousvous/features/orders-detail/screens/order_detail_screen.dart';
import 'package:vousvous/features/orders-detail/screens/tracking_detail_screen.dart';
import 'package:vousvous/features/orders/screens/orders_screen.dart';
import 'package:vousvous/features/otp-verify/screens/otp_verify_screen.dart';
import 'package:vousvous/features/product-detail/product_detail_screen.dart';
import 'package:vousvous/features/quotation-chat/screens/quotation_chat_screen.dart';
import 'package:vousvous/features/quotations/screens/quotations_screen.dart';
import 'package:vousvous/features/refer-friend/screens/refer_friend_screen.dart';
import 'package:vousvous/features/saved-address/screens/saved_address_screen.dart';
import 'package:vousvous/features/share-preview/screens/share_preview_screen.dart';
import 'package:vousvous/features/signup/screens/signup_screen.dart';
import 'package:vousvous/features/skipped/screens/skipped_screen.dart';
import 'package:vousvous/features/splash/screens/splash_screen.dart';
import 'package:vousvous/features/user-profile/screens/follower_list_screen.dart';
import 'package:vousvous/features/user-profile/screens/posts_view_screen.dart';
import 'package:vousvous/features/user-profile/screens/user_profile_screen.dart';
import 'package:vousvous/features/welcome/screens/welcome_screen.dart';

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
    // GetPage(
    //   opaque: false,
    //   transition: Transition.fadeIn,
    //   fullscreenDialog: true,
    //   name: Routes.myDesigns,
    //   page: () => MyDesignsScreen(),
    // ),
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
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.remixedProduct,
      page: () => RemixedProductScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.likedProduct,
      page: () => LikedProductScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.quotationChat,
      page: () => QuotationChatScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.inviteFriend,
      page: () => InviteFriendScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.sharePreview,
      page: () => SharePreviewScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.trackingDetail,
      page: () => TrackingDetailScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.userProfile,
      page: () => UserProfileScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.postsView,
      page: () => PostsViewScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.followerList,
      page: () => FollowerListScreen(),
    ),
    GetPage(
      opaque: false,
      transition: Transition.fadeIn,
      fullscreenDialog: true,
      name: Routes.referFriend,
      page: () => ReferFriendScreen(),
    ),
  ];
}
