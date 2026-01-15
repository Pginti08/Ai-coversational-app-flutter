import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
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
    // We expect "tag" to be passed if we want to find a specific controller instance
    // Or we can try to find the one related to the previous screen?
    // Actually, FollowerListScreen is pushed from UserProfileScreen.
    // UserProfileScreen now uses a tag.
    // So we should pass the tag to FollowerListScreen as well.
    // But if we don't change navigation arguments everywhere, we might break it.
    // Let's assume the previous screen is the one holding the controller.

    // However, simplest fix without changing all navigation calls:
    // If Get.arguments has a userId, we use that as tag?
    // Wait, UserProfileController is put with tag = userId.
    // So if we are viewing followers of userId 'X', we need to find controller with tag 'X'.
    // BUT, UserProfileController logic for followers is inside it.

    // Let's look at how we navigate to FollowerListScreen.
    // We might need to pass the userId/tag in arguments.

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
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.transparent,
                child: const Icon(Icons.arrow_back_ios,
                    color: AppColors.whiteColor, size: 20),
              ),
            ),
            centerTitle: true,
            title: Text(
              type == 'following' ? "Following" : "Followers",
              style: style600S18.copyWith(color: AppColors.whiteColor),
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isFollowersLoading.value) {
          return const Center(child: RotatingLoader());
        }

        if (controller.followers.isEmpty) {
          return Center(
            child: Text(
              type == 'following' ? "No following yet" : "No followers yet",
              style: style400S14.copyWith(color: AppColors.greyTextColor),
            ),
          );
        }

        return ListView.separated(
          padding:
              const EdgeInsets.only(top: 100, left: 16, right: 16, bottom: 20),
          itemCount: controller.followers.length +
              (controller.followersPaginationLoading.value ? 1 : 0),
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            if (index == controller.followers.length) {
              return const Center(child: RotatingLoader(size: 20));
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
                      arguments: {"userId": follower.id});
                }
              },
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
                      errorWidget:
                          const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          follower.name ?? "User",
                          style:
                              style600S16.copyWith(color: AppColors.whiteColor),
                        ),
                        if (follower.bio != null && follower.bio!.isNotEmpty)
                          Text(
                            follower.bio!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: style400S12.copyWith(
                                color: AppColors.greyTextColor),
                          ),
                      ],
                    ),
                  ),
                  if (follower.id !=
                      (LocalStorageService.instance.userInfo.value.data?.id ??
                          "")) ...[
                    const SizedBox(width: 10),
                    // Logic:
                    // If isFollowing == true => "Following" (Outlined)
                    // If isFollowing == false
                    //    If (isMyProfile && type == followers) => "Follow Back" (Primary)
                    //    Else => "Follow" (Primary)
                    AppButton(
                      onTap: () {
                        controller.toggleFollowFromList(index);
                      },
                      height: 32,
                      width: 100,
                      borderRadius: 8,
                      fontSize: 12,
                      text: (follower.isFollowing ?? false)
                          ? "Following"
                          : (controller.isYou && type == 'followers')
                              ? "Follow Back"
                              : "Follow",
                      isOutlined: (follower.isFollowing ?? false),
                      backgroundColor: (follower.isFollowing ?? false)
                          ? Colors.transparent
                          : null,
                      gradientColors: (follower.isFollowing ?? false)
                          ? null
                          : AppColors.colorGradient,
                      borderColor: (follower.isFollowing ?? false)
                          ? AppColors.greyTextColor
                          : null,
                      textColor: (follower.isFollowing ?? false)
                          ? AppColors.whiteColor
                          : AppColors.blackColor,
                    ),
                  ],
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
