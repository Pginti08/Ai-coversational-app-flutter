import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/core/widgets/image_viewer_screen.dart';
import 'package:vousvous/core/widgets/shimmer_utils.dart';
import 'package:vousvous/features/product-detail/controller/product_detail_controller.dart';
import 'package:vousvous/features/user-profile/controller/user_profile_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class UserProfileScreen extends StatelessWidget {
  UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserProfileController controller =
        Get.put(UserProfileController(), tag: Get.arguments?['userId']);
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (Get.isRegistered<ProductDetailController>()) {
          Get.find<ProductDetailController>().getProductDetail();
        }
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: CustomScaffold(
          isBottomEffect: false,
          resizeToAvoidBottomInset: false,
          isEffect3: true,
          isBottomSafeArea: false,
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() => controller.isLoading.value
                            ? shimmer(
                                child: shimmerContainer(
                                  width: 80,
                                  height: 18,
                                  borderRadius: 4,
                                ),
                              )
                            : Text(
                                controller.userDetail.value.data?.name ?? "-",
                                textAlign: TextAlign.center,
                                style: style600S16.copyWith(
                                    letterSpacing: 0.96,
                                    color: Color(0xFFCCCCCC)))),
                      ],
                    ),
                    Positioned(
                      left: 0,
                      child: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: SvgPicture.asset(
                          AssetConstants.backward,
                          height: 26,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics()
                      .applyTo(const BouncingScrollPhysics()),
                  padding: EdgeInsets.zero,
                  children: [
                    Obx(
                      () => Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        child: controller.isLoading.value
                            ? userDetailLoadingShimmer()
                            : Column(
                                children: [
                                  hSizedBox10,
                                  Obx(
                                    () => Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            String? imageUrl = controller
                                                .userDetail.value.data?.image;
                                            if (imageUrl != null &&
                                                imageUrl.isNotEmpty) {
                                              Get.to(() => ImageViewerScreen(
                                                  imageUrls: [imageUrl]));
                                            }
                                          },
                                          child: CommonContainer(
                                            width: 100,
                                            height: 100,
                                            isCircle: true,
                                            borderGradientColors:
                                                AppColors.colorGradient,
                                            backgroundColor: AppColors
                                                .blackColor
                                                .withOpacity(1),
                                            child: AppNetworkImage(
                                              imageUrl: controller.userDetail
                                                      .value.data?.image ??
                                                  "",
                                              shape: BoxShape.circle,
                                              fit: BoxFit.cover,
                                              errorWidget: Container(
                                                width: 100,
                                                height: 100,
                                                color: AppColors
                                                    .lightGreyTextColor
                                                    .withAlpha(30),
                                                padding: EdgeInsets.all(24),
                                                alignment: Alignment.center,
                                                child: SvgPicture.asset(
                                                  AssetConstants.user,
                                                  color: AppColors.whiteColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        wSizedBox16,
                                        Expanded(
                                            child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                controller.userDetail.value.data
                                                        ?.name ??
                                                    "-",
                                                textAlign: TextAlign.center,
                                                style: style700S16.copyWith(
                                                    color: Color(0xFFCCCCCC))),
                                            hSizedBox10,
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          (controller
                                                                      .userDetail
                                                                      .value
                                                                      .data
                                                                      ?.productsCount ??
                                                                  0)
                                                              .toString(),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: style500S18.copyWith(
                                                              letterSpacing:
                                                                  0.36,
                                                              color: AppColors
                                                                  .whiteColor)),
                                                      Text("Posts",
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          style: style300S14.copyWith(
                                                              letterSpacing:
                                                                  0.42,
                                                              color: AppColors
                                                                  .whiteColor)),
                                                    ],
                                                  ),
                                                ),
                                                wSizedBox10,
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Get.toNamed(
                                                          Routes.followerList,
                                                          arguments: {
                                                            "userId": controller
                                                                    .userId
                                                                    .isEmpty
                                                                ? (controller
                                                                        .userDetail
                                                                        .value
                                                                        .data
                                                                        ?.id ??
                                                                    "")
                                                                : controller
                                                                    .userId,
                                                          });
                                                    },
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              (controller
                                                                          .userDetail
                                                                          .value
                                                                          .data
                                                                          ?.followersCount ??
                                                                      0)
                                                                  .toString(),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: style500S18.copyWith(
                                                                  letterSpacing:
                                                                      0.36,
                                                                  color: AppColors
                                                                      .whiteColor)),
                                                          Text("Follower",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: style300S14.copyWith(
                                                                  letterSpacing:
                                                                      0.42,
                                                                  color: AppColors
                                                                      .whiteColor)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                wSizedBox10,
                                                Expanded(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Get.toNamed(
                                                          Routes.followerList,
                                                          arguments: {
                                                            "type": "following",
                                                            "userId": controller
                                                                    .userId
                                                                    .isEmpty
                                                                ? (controller
                                                                        .userDetail
                                                                        .value
                                                                        .data
                                                                        ?.id ??
                                                                    "")
                                                                : controller
                                                                    .userId,
                                                          });
                                                    },
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                              (controller
                                                                          .userDetail
                                                                          .value
                                                                          .data
                                                                          ?.followingCount ??
                                                                      0)
                                                                  .toString(),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: style500S18.copyWith(
                                                                  letterSpacing:
                                                                      0.36,
                                                                  color: AppColors
                                                                      .whiteColor)),
                                                          Text("Following",
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                              style: style300S14.copyWith(
                                                                  letterSpacing:
                                                                      0.42,
                                                                  color: AppColors
                                                                      .whiteColor)),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ))
                                      ],
                                    ),
                                  ),
                                  hSizedBox10,
                                  if (isNotNullOrEmpty(
                                      controller.userDetail.value.data?.bio))
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        controller.userDetail.value.data?.bio ??
                                            "",
                                        textAlign: TextAlign.start,
                                        style: style400S14.copyWith(
                                          color: const Color(0xFFACACAC),
                                        ),
                                      ),
                                    ),
                                  hSizedBox16,
                                  controller.isYou == true
                                      ? AppButton(
                                          onTap: () {
                                            Get.toNamed(Routes.editProfile);
                                          },
                                          text: "Edit Profile",
                                          borderColor: AppColors
                                              .lightGreyTextColor
                                              .withAlpha(70),
                                          textColor:
                                              AppColors.lightGreyTextColor,
                                          backgroundColor: AppColors
                                              .greyBorderColor
                                              .withAlpha(150),
                                        )
                                      : Obx(() => controller.isFollowing.value
                                          ? AppButton(
                                              onTap: controller
                                                      .isFollowLoading.value
                                                  ? null
                                                  : () {
                                                      controller.toggleFollow();
                                                    },
                                              text: controller
                                                      .isFollowLoading.value
                                                  ? "..."
                                                  : "Following",
                                              isOutlined: true,
                                              textColor: AppColors.whiteColor,
                                              gradientBorderColors:
                                                  AppColors.colorGradient,
                                            )
                                          : AppButton(
                                              onTap: controller
                                                      .isFollowLoading.value
                                                  ? null
                                                  : () {
                                                      controller.toggleFollow();
                                                    },
                                              text: controller
                                                      .isFollowLoading.value
                                                  ? "..."
                                                  : "Follow",
                                              textColor: AppColors.blackColor,
                                            )),
                                ],
                              ),
                      ),
                    ),

                    Divider(),

                    // Posts Grid
                    Obx(() => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 10),
                          child: controller.isLoading2.value
                              ? postsGridShimmer()
                              : controller.posts.length == 0
                                  ? Padding(
                                      padding: EdgeInsets.only(top: 120),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CommonContainer(
                                            padding: EdgeInsets.all(30),
                                            isCircle: true,
                                            borderColor: AppColors
                                                .lightGreyTextColor
                                                .withAlpha(100),
                                            child: SvgPicture.asset(
                                              AssetConstants.camera,
                                              height: 28,
                                            ),
                                          ),
                                          hSizedBox6,
                                          Text(
                                            "No post yet",
                                            style: style400S14,
                                          )
                                        ],
                                      ),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 2,
                                        mainAxisSpacing: 2,
                                        childAspectRatio: 1,
                                      ),
                                      itemCount: controller.posts.length,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            Get.toNamed(Routes.postsView,
                                                arguments: {
                                                  "posts": controller.posts,
                                                  "initialIndex": index,
                                                  "userName": controller
                                                      .userDetail
                                                      .value
                                                      .data
                                                      ?.name,
                                                  "userAvatar": controller
                                                      .userDetail
                                                      .value
                                                      .data
                                                      ?.image,
                                                  "userId":
                                                      controller.userId.isEmpty
                                                          ? (controller
                                                                  .userDetail
                                                                  .value
                                                                  .data
                                                                  ?.id ??
                                                              "")
                                                          : controller.userId,
                                                });
                                          },
                                          child: Stack(
                                            children: [
                                              AppNetworkImage(
                                                imageUrl: controller
                                                        .posts[index].image ??
                                                    "",
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              ),
                                              if (controller.isYou)
                                                Positioned(
                                                    right: 5,
                                                    top: 5,
                                                    child: SvgPicture.asset(
                                                      (controller.posts[index]
                                                                  .isPrivate ??
                                                              true)
                                                          ? AssetConstants
                                                              .private
                                                          : AssetConstants
                                                              .public,
                                                      color:
                                                          AppColors.grey2Color,
                                                      width: 16,
                                                    )),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                        )),

                    Obx(() => controller.paginationLoading.value
                        ? Padding(
                            padding: EdgeInsets.all(8),
                            child: Center(
                              child: RotatingLoader(
                                size: 30,
                              ),
                            ),
                          )
                        : SizedBox.shrink()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column userDetailLoadingShimmer() {
    return Column(
      children: [
        hSizedBox10,
        Row(
          children: [
            shimmer(
              child: shimmerContainer(
                width: 100,
                height: 100,
                borderRadius: 100,
              ),
            ),
            wSizedBox16,
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  shimmer(
                    child: shimmerContainer(
                      width: 150,
                      height: 15,
                      borderRadius: 4,
                    ),
                  ),
                  hSizedBox16,
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            shimmer(
                              child: shimmerContainer(
                                width: 40,
                                height: 25,
                                borderRadius: 4,
                              ),
                            ),
                            hSizedBox6,
                            shimmer(
                              child: shimmerContainer(
                                width: 70,
                                height: 12,
                                borderRadius: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      wSizedBox10,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            shimmer(
                              child: shimmerContainer(
                                width: 40,
                                height: 25,
                                borderRadius: 4,
                              ),
                            ),
                            hSizedBox6,
                            shimmer(
                              child: shimmerContainer(
                                width: 70,
                                height: 12,
                                borderRadius: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      wSizedBox10,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            shimmer(
                              child: shimmerContainer(
                                width: 40,
                                height: 25,
                                borderRadius: 4,
                              ),
                            ),
                            hSizedBox6,
                            shimmer(
                              child: shimmerContainer(
                                width: 70,
                                height: 12,
                                borderRadius: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        hSizedBox20,
        shimmer(
          child: shimmerContainer(
            width: double.infinity,
            height: 40,
            borderRadius: 100,
          ),
        ),
      ],
    );
  }

  Widget postsGridShimmer({int rows = 5}) {
    const int columns = 3;
    final int itemCount = rows * columns;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 1,
      ),
      itemBuilder: (_, __) {
        return shimmer(
          child: shimmerContainer(
            width: double.infinity,
            height: double.infinity,
            borderRadius: 0, // square grid
          ),
        );
      },
    );
  }
}
