import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';
import 'package:vousvous/core/constants/flavors.dart';
import 'package:vousvous/core/constants/storage_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/theme/app_theme.dart';
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

class App extends StatelessWidget {
  const App({super.key});

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
