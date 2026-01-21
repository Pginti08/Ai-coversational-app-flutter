import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/common_dialog.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/home/controller/home_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

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
                  onTap: () {
                    widget.controller.toggleDrawer();
                    Get.toNamed(Routes.userProfile, arguments: {
                      "userId":
                          LocalStorageService.instance.userInfo.value.data?.id
                    });
                  },
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8)
                      .copyWith(right: 0),
                  borderRadius: 16,
                  backgroundColor: AppColors.whiteColor.withAlpha(20),
                  enableBlur: true,
                  child: Row(
                    children: [
                      Obx(() => AppNetworkImage(
                            width: 40,
                            height: 40,
                            shape: BoxShape.circle,
                            imageUrl: LocalStorageService
                                    .instance.userInfo.value.data?.image ??
                                "",
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              width: 40,
                              height: 40,
                              color: AppColors.lightGreyTextColor.withAlpha(30),
                              padding: EdgeInsets.all(8),
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                AssetConstants.user,
                                color: AppColors.whiteColor,
                              ),
                            ),
                          )),
                      wSizedBox8,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (LocalStorageService.instance.userInfo.value.data
                                              ?.name ??
                                          "")
                                      .capitalize ??
                                  "",
                              overflow: TextOverflow.ellipsis,
                              style: style400S16.copyWith(
                                letterSpacing: 0.32,
                                color: AppColors.whiteTextColor,
                              ),
                            ),
                            Text(
                              "${LocalStorageService.instance.userInfo.value.data?.countryCode ?? ""} ${LocalStorageService.instance.userInfo.value.data?.phone ?? ""}",
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
                          onPressed: () {
                            widget.controller.toggleDrawer();
                            Get.toNamed(Routes.userProfile);
                          },
                          icon: Transform.rotate(
                              angle: 3.14159,
                              child: SvgPicture.asset(
                                AssetConstants.backward,
                                height: 24,
                              )))
                      // IconButton(
                      //     onPressed: () {
                      //       widget.controller.toggleDrawer();
                      //       Get.toNamed(Routes.editProfile);
                      //     },
                      //     icon: SvgPicture.asset(
                      //       AssetConstants.edit,
                      //       width: 24,
                      //     ))
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
                    name: "Body Profile",
                    icon: AssetConstants.rulerPen,
                    onTap: () {
                      Get.toNamed(Routes.bodyProfile);
                    },
                  ),
                  menuTiles(
                    name: "Saved Addresses",
                    icon: AssetConstants.personalCard,
                    onTap: () {
                      Get.toNamed(Routes.savedAddress);
                    },
                  ),
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
                    name: "Refer a Friend",
                    icon: AssetConstants.gift,
                    onTap: () {
                      Get.toNamed(Routes.referFriend);
                    },
                  ),
                  // menuTiles(
                  //   name: "Invite Friends",
                  //   icon: AssetConstants.share,
                  //   onTap: () {
                  //     Get.toNamed(Routes.inviteFriend);
                  //   },
                  // ),
                  menuTiles(
                    name: "Logout",
                    icon: AssetConstants.logout,
                    isToggle: false,
                    onTap: () async {
                      commonDialog(
                        title: "Logout",
                        description: "Are you sure you want to logout?",
                        successButtonTitle: "Logout",
                        cancelButtonTitle: "Cancel",
                        onSuccess: () async {
                          Get.back();
                          await LocalStorageService.instance.clear();
                          Get.offAllNamed(Routes.login);
                        },
                      );
                    },
                  ),
                ],
              )),
              hSizedBox12,
              // Divider(
              //   thickness: 0.5,
              //   color: AppColors.dividerColor,
              // ),
              // hSizedBox12,
              // Padding(
              //   padding: EdgeInsets.symmetric(horizontal: 12.w),
              //   child: Column(
              //     children: [
              //       AppButton(
              //         onTap: () {
              //           widget.controller.toggleDrawer();
              //           Get.toNamed(Routes.myDesigns);
              //         },
              //         child: Row(
              //           mainAxisAlignment: MainAxisAlignment.center,
              //           children: [
              //             SvgPicture.asset(AssetConstants.colorfilter),
              //             wSizedBox6,
              //             Text("My Designs",
              //                 style: style700S16.copyWith(
              //                     color: AppColors.blackColor)),
              //           ],
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              if (Platform.isAndroid) hSizedBox10,
            ],
          ),
        ),
      ),
    );
  }

  Widget menuTiles(
      {required String icon,
      required String name,
      void Function()? onTap,
      bool isToggle = true}) {
    return GestureDetector(
      onTap: () {
        if (isToggle) {
          widget.controller.toggleDrawer();
        }
        onTap?.call();
      },
      child: Container(
        color: Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        child: Row(
          children: [
            SvgPicture.asset(
              icon,
              height: 20,
              colorFilter: ColorFilter.mode(Color(0xFFCCCCCC), BlendMode.srcIn),
            ),
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
