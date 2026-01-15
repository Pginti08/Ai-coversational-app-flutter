import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/user-profile/controller/posts_view_controller.dart';
import 'package:vousvous/features/user-profile/screens/edit_post_bottom_sheet.dart';

class PostsViewScreen extends StatefulWidget {
  const PostsViewScreen({Key? key}) : super(key: key);

  @override
  State<PostsViewScreen> createState() => _PostsViewScreenState();
}

class _PostsViewScreenState extends State<PostsViewScreen> {
  final PostsViewController controller = Get.put(PostsViewController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isBottomEffect: false,
      resizeToAvoidBottomInset: false,
      isEffect3: true,
      isBottomSafeArea: false,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Posts",
                      textAlign: TextAlign.center,
                      style: style700S16.copyWith(
                          letterSpacing: 0.96, color: Color(0xFFCCCCCC))),
                ],
              ),
              Positioned(
                left: 0,
                child: IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: SvgPicture.asset(AssetConstants.backward),
                ),
              ),
            ],
          ),
          hSizedBox20,
          Expanded(
            child: Obx(() => ScrollablePositionedList.builder(
                  itemScrollController: controller.itemScrollController,
                  itemPositionsListener: controller.itemPositionsListener,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.posts.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.posts.length) {
                      return Padding(
                          padding: EdgeInsets.all(8),
                          child: Center(
                            child: RotatingLoader(
                              size: 30,
                            ),
                          ));
                    }
                    final postIndex = index;
                    return Obx(() {
                      final post = controller.posts[postIndex];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User info header
                            Row(
                              children: [
                                AppNetworkImage(
                                  imageUrl: controller.userAvatar.value ?? "",
                                  width: 32,
                                  height: 32,
                                  shape: BoxShape.circle,
                                  fit: BoxFit.cover,
                                  errorWidget: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: AppColors.lightGreyTextColor
                                          .withAlpha(30),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person,
                                        color: Colors.white, size: 18),
                                  ),
                                ),
                                wSizedBox12,
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        controller.userName.value ?? "User",
                                        overflow: TextOverflow.ellipsis,
                                        style: style600S14.copyWith(
                                            color: Colors.white),
                                      ),
                                      Text(
                                        post.isPrivate == true
                                            ? "Private Post"
                                            : "Public Post",
                                        style: style400S10.copyWith(
                                            color: post.isPrivate == true
                                                ? Colors.orange
                                                : Colors.green),
                                      ),
                                    ],
                                  ),
                                ),
                                if (controller.userProfileController.isYou)
                                  IconButton(
                                    icon: const Icon(Icons.more_vert,
                                        color: Colors.white),
                                    onPressed: () =>
                                        _showPostOptions(context, post),
                                  ),
                              ],
                            ),

                            hSizedBox12,
                            // Post image
                            AppNetworkImage(
                              imageUrl: post.image ?? "",
                              fit: BoxFit.fitWidth,
                              width: double.infinity,
                              borderRadius: BorderRadius.circular(16),
                              isOpenImageViewer: true,
                            ),

                            hSizedBox12,

                            // Action Buttons Row (Instagram Style)
                            Row(
                              children: [
                                _actionButton(
                                  icon: post.isLiked == true
                                      ? AssetConstants.heart
                                      : AssetConstants.heart2,
                                  color: post.isLiked == true
                                      ? Colors.red
                                      : Colors.white,
                                  label: post.likesCount != null &&
                                          post.likesCount! > 0
                                      ? post.likesCount.toString()
                                      : "",
                                  onTap: () {
                                    if (post.id != null) {
                                      controller.likePost(post.id!);
                                    }
                                  },
                                ),
                                wSizedBox12,
                                _actionButton(
                                  icon: AssetConstants.share,
                                  color: Colors.white,
                                  onTap: () => shareUrl(
                                    text:
                                        "Check out this outfit: ${post.title}\n${post.image}",
                                  ),
                                ),
                                const Spacer(),
                                // Remix (Magic Pen) Button
                                CommonContainer(
                                  onTap: () =>
                                      controller.remixPost(post.image ?? ""),
                                  padding: const EdgeInsets.all(8),
                                  borderRadius: 12,
                                  backgroundColor:
                                      AppColors.whiteColor.withAlpha(20),
                                  borderColor:
                                      AppColors.whiteColor.withAlpha(40),
                                  child: SvgPicture.asset(
                                    AssetConstants.magicpen,
                                    width: 18,
                                    height: 18,
                                    colorFilter: const ColorFilter.mode(
                                        Colors.white, BlendMode.srcIn),
                                  ),
                                ),
                                wSizedBox8,

                                // Get Quote Button
                                Obx(() {
                                  final isThisLoading =
                                      controller.isQuotationLoading.value &&
                                          controller.activeQuotationUrl.value ==
                                              post.image;
                                  return GestureDetector(
                                    onTap: isThisLoading
                                        ? null
                                        : () => controller.checkQuotationStatus(
                                            context, post.image ?? ""),
                                    behavior: HitTestBehavior.opaque,
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 8),
                                      constraints: const BoxConstraints(
                                        minWidth: 110,
                                        minHeight: 32,
                                      ),
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                            color: AppColors.whiteColor
                                                .withAlpha(100)),
                                        borderRadius: BorderRadius.circular(20),
                                        gradient: LinearGradient(
                                          colors: isThisLoading
                                              ? [
                                                  Colors.grey.shade800,
                                                  Colors.grey.shade900
                                                ]
                                              : AppColors.colorGradient,
                                        ),
                                      ),
                                      child: isThisLoading
                                          ? const SizedBox(
                                              height: 16,
                                              width: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                        Color>(Colors.white),
                                              ),
                                            )
                                          : Text(
                                              "Get Quotation",
                                              style: style700S12.copyWith(
                                                  color: Colors.black),
                                            ),
                                    ),
                                  );
                                }),
                              ],
                            ),

                            hSizedBox12,

                            Text(
                              post.title ?? "",
                              style: style800S16.copyWith(
                                  color: const Color(0xFF68C3E7)),
                            ),
                            hSizedBox8,
                            ReadMoreText(
                              post.description ?? "",
                              textAlign: TextAlign.left,
                              style: style400S14.copyWith(
                                  color: Colors.white.withAlpha(200)),
                              trimLines: 3,
                              trimMode: TrimMode.Line,
                              moreStyle: style600S14.copyWith(
                                  color: const Color(0xFFFFB86B)),
                              lessStyle: style600S14.copyWith(
                                  color: const Color(0xFFFFB86B)),
                              trimCollapsedText: 'Show more',
                              trimExpandedText: ' Show less',
                            ),

                            hSizedBox8,

                            // Timestamp
                            Text(
                              formatTimeAgo(post.updatedAt),
                              style:
                                  style400S12.copyWith(color: Colors.white60),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
      {required String icon,
      required Color color,
      String? label,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: () {
        debugPrint("💓 Action button tapped: $icon");
        if (onTap != null) onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              width: 24,
            ),
            if (label != null && label.isNotEmpty) ...[
              wSizedBox4,
              Text(label, style: style500S14.copyWith(color: Colors.white)),
            ],
          ],
        ),
      ),
    );
  }

  void _showPostOptions(BuildContext context, dynamic post) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.scaffoldColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(color: AppColors.whiteColor.withAlpha(40)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            hSizedBox10,
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            hSizedBox20,
            _menuTile(
              icon: Icons.edit_outlined,
              label: "Edit Post",
              onTap: () {
                Get.back();
                BlurBottomSheet().show<void>(
                  heightType: BottomSheetHeightType.maxHeight,
                  height: MediaQuery.sizeOf(context).height * 0.85,
                  context: context,
                  borderColor: AppColors.whiteColor.withAlpha(40),
                  backgroundColor: AppColors.scaffoldColor,
                  barrierColor: AppColors.blackColor.withAlpha(150),
                  blurStrength: 30,
                  isCloseButton: false,
                  child: EditPostBottomSheet(product: post),
                );
              },
            ),
            _menuTile(
              icon: Icons.delete_outline,
              label: "Delete Post",
              color: Colors.red,
              onTap: () {
                Get.back();
                _showDeleteConfirmation(context, post.id!);
              },
            ),
            hSizedBox20,
          ],
        ),
      ),
    );
  }

  Widget _menuTile(
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      Color color = Colors.white}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: style600S16.copyWith(color: color)),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation(BuildContext context, String productId) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.scaffoldColor,
        title: Text("Delete Post",
            style: style700S18.copyWith(color: Colors.white)),
        content: Text("Are you sure you want to delete this post?",
            style: style400S14.copyWith(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: Text("Cancel",
                  style: style600S14.copyWith(color: Colors.white60))),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deletePost(productId);
            },
            child:
                Text("Delete", style: style600S14.copyWith(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
