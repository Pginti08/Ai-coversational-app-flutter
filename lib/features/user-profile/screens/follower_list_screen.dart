import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/user-profile/controller/user_profile_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class FollowerListScreen extends StatefulWidget {
  const FollowerListScreen({super.key});

  @override
  State<FollowerListScreen> createState() => _FollowerListScreenState();
}

class _FollowerListScreenState extends State<FollowerListScreen> {
  late final UserProfileController controller;

  String type = 'followers';

  @override
  void initState() {
    super.initState();
    String? tag;
    
    if (Get.arguments != null) {
      if (Get.arguments["type"] != null) {
        type = Get.arguments["type"];
      }
      // Try to find controller with tag if passed, or fallback
      if (Get.arguments['userId'] != null) {
        tag = Get.arguments['userId'];
      }
    }

    try {
      controller = Get.find<UserProfileController>(tag: tag);
    } catch (e) {
      // Fallback if no specific tag found (e.g. main/self profile)
      controller = Get.find<UserProfileController>();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getFollowersApi(type: type);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        isBottomEffect: false,
        body: Obx(
          () => Column(
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
                        Text(
                            (type == 'following' ? "Following" : "Followers")
                                .toUpperCase(),
                            textAlign: TextAlign.center,
                            style: style600S14.copyWith(
                                letterSpacing: 0.96, color: Color(0xFFCCCCCC))),
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
                  child: (controller.isFollowersLoading.value)
                      ? const Center(child: RotatingLoader())
                      : (controller.followers.isEmpty)
                          ? Center(
                              child: Text(
                                type == 'following'
                                    ? "No following yet"
                                    : "No followers yet",
                                style: style400S14.copyWith(
                                    color: AppColors.greyTextColor),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              padding: const EdgeInsets.all(16),
                              itemCount: controller.followers.length +
                                  (controller.followersPaginationLoading.value
                                      ? 1
                                      : 0),
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 16),
                              itemBuilder: (context, index) {
                                if (index == controller.followers.length) {
                                  return const Center(
                                      child: RotatingLoader(size: 20));
                                }

                                final follower = controller.followers[index];

                                // DEBUG: Log follower data
                                if (index == 0) {
                                  print(
                                      "🔍 UI Rendering - First follower: ${follower.name}, isFollowing: ${follower.isFollowing}");
                                }

                                return GestureDetector(
                                  onTap: () {
                                    // Navigate to user profile
                                    if (follower.id != null) {
                                      Get.toNamed(Routes.userProfile,
                                          arguments: {"userId": follower.id},
                                          preventDuplicates: true);
                                    }
                                  },
                                  child: Container(
                                    color: Colors.transparent,
                                    child: Row(
                                      children: [
                                        CommonContainer(
                                          width: 50,
                                          height: 50,
                                          isCircle: true,
                                          backgroundColor: AppColors.grey2Color,
                                          child: AppNetworkImage(
                                            imageUrl: follower.image ?? "",
                                            shape: BoxShape.circle,
                                            fit: BoxFit.cover,
                                            errorWidget: const Icon(
                                                Icons.person,
                                                color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                follower.username ?? "-",
                                                style: style600S16.copyWith(
                                                    color:
                                                        AppColors.whiteColor),
                                              ),
                                              if (isNotNullOrEmpty(
                                                  follower.name))
                                                Text(
                                                  follower.name ?? "",
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: style400S12.copyWith(
                                                      color: AppColors
                                                          .greyTextColor),
                                                ),
                                            ],
                                          ),
                                        ),
                                        if (follower.id !=
                                            (LocalStorageService.instance
                                                    .userInfo.value.data?.id ??
                                                "")) ...[
                                          const SizedBox(width: 10),
                                          // Logic:
                                          // If isFollowing == true => "Following" (Outlined)
                                          // If isFollowing == false
                                          //    If (isMyProfile && type == followers) => "Follow Back" (Primary)
                                          //    Else => "Follow" (Primary)
                                          AppButton(
                                            onTap: () {
                                              controller
                                                  .toggleFollowFromList(index);
                                            },
                                            height: 32,
                                            width: 100,
                                            borderRadius: 8,
                                            fontSize: 12,
                                            text:
                                                (follower.isFollowing ?? false)
                                                    ? "Following"
                                                    : (controller.isYou &&
                                                            type == 'followers')
                                                        ? "Follow Back"
                                                        : "Follow",
                                            isOutlined:
                                                (follower.isFollowing ?? false),
                                            backgroundColor:
                                                (follower.isFollowing ?? false)
                                                    ? Colors.transparent
                                                    : null,
                                            gradientColors:
                                                (follower.isFollowing ?? false)
                                                    ? null
                                                    : AppColors.colorGradient,
                                            borderColor:
                                                (follower.isFollowing ?? false)
                                                    ? AppColors.greyTextColor
                                                    : null,
                                            textColor:
                                                (follower.isFollowing ?? false)
                                                    ? AppColors.whiteColor
                                                    : AppColors.blackColor,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ))
            ],
          ),
        ));
  }
}
