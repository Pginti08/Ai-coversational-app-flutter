import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:vousvous/core/constants/flavors.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/deep_link_service.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/theme/app_theme.dart';
import 'package:vousvous/features/splash/screens/splash_screen.dart';
import 'package:vousvous/routes/app_pages.dart';

Future<void> bootstrap(
  FutureOr<Widget> Function() builder,
  FlavorType env,
) async {
  Flavor.setFlavor = env;

  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar text and icons to dark
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark, // For iOS
      statusBarIconBrightness: Brightness.light, // For Android
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.black,
    ),
  );

  // Initialize LocalStorageService
  await LocalStorageService.instance.init();

  runApp(await builder());
}

class App extends StatefulWidget {
  App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final DeepLinkHandler _deepLinkHandler = DeepLinkHandler();

  @override
  void initState() {
    super.initState();

    Get.put<DeepLinkHandler>(_deepLinkHandler, permanent: true);

    _deepLinkHandler.initDeepLinks();
  }

  @override
  void dispose() {
    _deepLinkHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
        LocalStorageService.instance.getString(StorageConstants.accessToken));
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, child) {
        return ToastificationWrapper(
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            initialRoute: Routes.splash,
            getPages: AppPages.routes,
            unknownRoute: GetPage(
              name: '/notfound',
              page: () =>
                  SplashScreen(), // Redirects the unknown deep link path to Splash
              transition: Transition.fadeIn,
            ),
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(
                  context,
                ).copyWith(textScaler: const TextScaler.linear(1.0)),
                child: child!,
              );
            },
          ),
        );
      },
    );
  }
}
