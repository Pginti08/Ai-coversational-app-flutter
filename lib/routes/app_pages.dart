import 'package:ai_fashion/features/chat/screens/chat_screen.dart';
import 'package:ai_fashion/features/chat/sub-features/brand_search/brand_search_screen.dart';
import 'package:ai_fashion/features/chat/sub-features/card-deck/card_deck_screen.dart';
import 'package:ai_fashion/features/home/screens/home_screen.dart';
import 'package:ai_fashion/features/liked/screens/liked_screen.dart';
import 'package:ai_fashion/features/my_designs/screens/my_designs_screen.dart';
import 'package:ai_fashion/features/outfit-detail/outfit_detail_screen.dart';
import 'package:ai_fashion/features/skipped/screens/skipped_screen.dart';
import 'package:ai_fashion/features/splash/screens/splash_screen.dart';
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
      name: Routes.outfitDetail,
      page: () => OutfitDetailScreen(),
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
  ];
}
