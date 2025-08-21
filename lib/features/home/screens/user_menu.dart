import 'dart:io';

import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/home/controller/home_controller.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/route_manager.dart';

class UserMenu extends StatefulWidget {
  const UserMenu({required this.controller, super.key});
  final HomeController controller;

  @override
  State<UserMenu> createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      scaffoldColor: Color(0xFF121212),
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: CommonContainer(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)
                      .copyWith(right: 0),
                  borderRadius: 16,
                  backgroundColor: AppColors.whiteColor.withAlpha(20),
                  enableBlur: true,
                  child: Row(
                    children: [
                      AppNetworkImage(
                        width: 40,
                        height: 40,
                        shape: BoxShape.circle,
                        imageUrl:
                            "https://images.unsplash.com/photo-1619895862022-09114b41f16f?fm=jpg&q=60&w=3000&ixlib=rb-4.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8d29tZW4lMjBwcm9maWxlJTIwcGljdHVyZXxlbnwwfHwwfHx8MA%3D%3D",
                        fit: BoxFit.cover,
                        errorWidget: Container(
                          width: 40,
                          height: 40,
                          color: AppColors.grey2Color,
                          padding: EdgeInsets.all(8),
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            AssetConstants.user,
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                      wSizedBox8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Amelie Clarke",
                              overflow: TextOverflow.ellipsis,
                              style: style400S16.copyWith(
                                letterSpacing: 0.32,
                                color: AppColors.whiteTextColor,
                              ),
                            ),
                            Text(
                              "+91 88299-92878",
                              overflow: TextOverflow.ellipsis,
                              style: style400S14.copyWith(
                                letterSpacing: 0.28,
                                color: Color(0xFF999999),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                          onPressed: () {},
                          icon: SvgPicture.asset(
                            AssetConstants.edit,
                            width: 24,
                          ))
                    ],
                  ),
                ),
              ),
              hSizedBox6,
              Expanded(
                  child: ListView(
                children: [
                  menuTiles(
                    name: "Orders",
                    icon: AssetConstants.box,
                    onTap: () {
                      Get.toNamed(Routes.orders);
                    },
                  ),
                  menuTiles(
                    name: "Cart",
                    icon: AssetConstants.cart,
                    onTap: () {
                      Get.toNamed(Routes.cart);
                    },
                  ),
                  menuTiles(
                    name: "Quotations",
                    icon: AssetConstants.document,
                    onTap: () {
                      Get.toNamed(Routes.quotations);
                    },
                  ),
                  menuTiles(
                      name: "Body Profile", icon: AssetConstants.rulerPen),
                  menuTiles(
                    name: "Liked Designs",
                    icon: AssetConstants.heart2,
                    onTap: () {
                      Get.toNamed(Routes.liked);
                    },
                  ),
                  menuTiles(
                    name: "Skipped Designs",
                    icon: AssetConstants.previous2,
                    onTap: () {
                      Get.toNamed(Routes.skipped);
                    },
                  ),
                  menuTiles(
                      name: "Saved Addresses",
                      icon: AssetConstants.personalCard),
                  menuTiles(name: "Invite Friends", icon: AssetConstants.share),
                ],
              )),
              hSizedBox12,
              Divider(
                thickness: 0.5,
                color: AppColors.dividerColor,
              ),
              hSizedBox12,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Column(
                  children: [
                    AppButton(
                      onTap: () {
                        Get.toNamed(Routes.myDesigns);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AssetConstants.colorfilter),
                          wSizedBox6,
                          Text("My Designs",
                              style: style700S16.copyWith(
                                  color: AppColors.blackColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (Platform.isAndroid) hSizedBox10,
            ],
          ),
        ),
      ),
    );
  }

  Widget menuTiles(
      {required String icon, required String name, void Function()? onTap}) {
    return GestureDetector(
      onTap: () {
        widget.controller.toggleDrawer();
        onTap?.call();
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Row(
          children: [
            SvgPicture.asset(icon),
            wSizedBox8,
            Text(
              name,
              style: style700S16.copyWith(color: Color(0xFFCCCCCC)),
            )
          ],
        ),
      ),
    );
  }
}
