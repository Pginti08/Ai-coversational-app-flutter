import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:readmore/readmore.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/common_dialog.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/user-profile/controller/posts_view_controller.dart';
import 'package:vousvous/features/user-profile/screens/edit_post_bottom_sheet.dart';

class PostsViewScreen extends StatefulWidget {
  const PostsViewScreen({Key? key}) : super(key: key);

  @override
  State<PostsViewScreen> createState() => _PostsViewScreenState();
}

// Method to download image and return file path
Future<String?> _downloadImage(String imageUrl) async {
  try {
    final response = await http.get(Uri.parse(imageUrl));
    if (response.statusCode == 200) {
      final documentDirectory = await getTemporaryDirectory();
      final file = File('${documentDirectory.path}/shared_product_image.jpg');
      await file.writeAsBytes(response.bodyBytes);
      return file.path;
    }
  } catch (e) {
    print('Error downloading image: $e');
  }
  return null;
}

class _PostsViewScreenState extends State<PostsViewScreen> {
  final PostsViewController controller = Get.put(PostsViewController());

  Future<void> _shareProduct(Product productDetail) async {
    try {
      // 1. Setup Data
      final imageUrl = productDetail.image ?? "";
      final productTitle = productDetail.title ?? '-';
      final productId = productDetail.id ?? '';
      final userName = productDetail.userName ?? '-';

      // 2. Create Link
      final String customLink =
          'https://vousvous.com/share?productId=$productId&imageUrl=$imageUrl';

      // 3. Create Message
      final String shareMessage = '''
✨ *${productTitle.toUpperCase()}* ✨

Check out this stunning outfit on *VOUSVOUS*! 👗✨

Designed by: $userName

🎨 Design your dream dress with intelligent styling
🔥 Discover unique fashion creations
💎 Connect with expert designers
🛍️ Get instant quotes effortlessly

Download *VOUSVOUS* now and bring your fashion vision to life!

👉 $customLink

#VOUSVOUS #DreamDress #IntelligentStyling #FashionDesign #StyleInspiration #OOTD
''';

      final String shareSubject =
          '✨ ${productTitle.toUpperCase()} - Fashion App';

      // 4. Prepare Files (if image exists)
      List<XFile> filesToShare = [];

      if (imageUrl.isNotEmpty) {
        final String? imagePath = await _downloadImage(imageUrl);
        if (imagePath != null && imagePath.isNotEmpty) {
          filesToShare.add(XFile(imagePath));
        }
      }

      // 5. Handle iPad Position (Optional but recommended)
      // iPad requires a source rect to anchor the share popup
      final box = context.findRenderObject() as RenderBox?;
      final Rect? shareOrigin =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      // 6. Execute Share using the NEW API
      // "Share.share" and "Share.shareXFiles" are replaced by "SharePlus.instance.share"
      // using a "ShareParams" object.
      await SharePlus.instance.share(
        ShareParams(
          text: shareMessage,
          subject: shareSubject,
          files: filesToShare, // Can be empty for text-only share
          sharePositionOrigin: shareOrigin, // Crucial for iPad
        ),
      );
    } catch (e) {
      debugPrint('Error sharing: $e');
      toast('Error sharing: $e');
    }
  }

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
                  icon: SvgPicture.asset(
                    AssetConstants.backward,
                    height: 24,
                  ),
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
                                wSizedBox6,
                                _actionButton(
                                    icon: AssetConstants.share,
                                    color: Colors.white,
                                    width: 20,
                                    onTap: () => _shareProduct(post)),
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
      double? width,
      void Function()? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              icon,
              colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
              width: width ?? 24,
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
    BlurBottomSheet().show<void>(
      height: MediaQuery.sizeOf(context).height * 0.175,
      context: context,
      borderColor: AppColors.whiteColor.withAlpha(40),
      backgroundColor: AppColors.scaffoldColor.withAlpha(200),
      barrierColor: AppColors.blackColor.withAlpha(150),
      blurStrength: 20,
      isCloseButton: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          hSizedBox10,
          _menuTile(
            icon: Icons.edit_outlined,
            label: "Edit Post",
            onTap: () {
              Get.back();
              BlurBottomSheet().show<void>(
                heightType: BottomSheetHeightType.maxHeight,
                height: MediaQuery.sizeOf(context).height,
                context: context,
                borderColor: AppColors.whiteColor.withAlpha(40),
                backgroundColor: AppColors.scaffoldColor.withAlpha(200),
                barrierColor: AppColors.blackColor.withAlpha(150),
                blurStrength: 20,
                isCloseButton: true,
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
    );
  }

  Widget _menuTile(
      {required IconData icon,
      required String label,
      required VoidCallback onTap,
      Color color = Colors.white}) {
    return ListTile(
      tileColor: Colors.transparent,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      selectedTileColor: Colors.transparent,
      leading: Icon(icon, color: color),
      title: Text(label, style: style600S16.copyWith(color: color)),
      onTap: onTap,
    );
  }

  void _showDeleteConfirmation(BuildContext context, String productId) {
    commonDialog(
      title: "Delete Post",
      description: "Are you sure you want to delete this post?",
      successButtonTitle: "Delete",
      cancelButtonTitle: "Cancel",
      onSuccess: () {
        Get.back();
        controller.deletePost(productId);
      },
    );
  }
}
