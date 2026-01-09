import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:readmore/readmore.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/user-profile/controller/posts_view_controller.dart';
import 'package:vousvous/features/user-profile/screens/change_visibility_bottom_sheet.dart';

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
          hSizedBox16,
          Expanded(
            child: Obx(() => ListView.builder(
                  controller: controller.scrollController,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: controller.posts.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show loading indicator at the end
                    if (index == controller.posts.length) {
                      return Container(
                        padding: EdgeInsets.all(20),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    return Container(
                      margin: EdgeInsets.only(bottom: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User info header
                          Row(
                            children: [
                              AppNetworkImage(
                                imageUrl: controller.userAvatar.value ?? "",
                                width: 24,
                                height: 24,
                                shape: BoxShape.circle,
                                fit: BoxFit.cover,
                                errorWidget: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: AppColors.lightGreyTextColor
                                        .withAlpha(30),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.person,
                                      color: Colors.white, size: 16),
                                ),
                              ),
                              wSizedBox8,
                              Expanded(
                                child: Text(
                                  controller.userName.value ?? "User",
                                  overflow: TextOverflow.ellipsis,
                                  style:
                                      style600S14.copyWith(color: Colors.white),
                                ),
                              ),
                              wSizedBox10,
                              if (isNotNullOrEmpty(
                                  controller.posts[index].isPrivate))
                                GestureDetector(
                                  onTap: () {
                                    BlurBottomSheet().show<void>(
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.4,
                                      context: context,
                                      borderColor:
                                          AppColors.whiteColor.withAlpha(40),
                                      backgroundColor: AppColors.scaffoldColor,
                                      barrierColor:
                                          AppColors.blackColor.withAlpha(150),
                                      blurStrength: 30,
                                      isCloseButton: true,
                                      child: ChangeVisibilityBottomSheet(
                                        product: controller.posts[index],
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(4),
                                    color: Colors.transparent,
                                    child: Row(
                                      children: [
                                        SvgPicture.asset(
                                          (controller.posts[index].isPrivate!)
                                              ? AssetConstants.private
                                              : AssetConstants.public,
                                          width: 16,
                                        ),
                                        wSizedBox2,
                                        Text(
                                          ((controller.posts[index].isPrivate!)
                                                  ? "private"
                                                  : "public")
                                              .toUpperCase(),
                                          style: style500S10,
                                        )
                                      ],
                                    ),
                                  ),
                                )
                            ],
                          ),

                          hSizedBox10,
                          // Post image
                          AppNetworkImage(
                            imageUrl: controller.posts[index].image ?? "",
                            fit: BoxFit.fitWidth,
                            width: double.infinity,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          hSizedBox10,
                          Text(
                            controller.posts[index].title ?? "",
                            style:
                                style800S16.copyWith(color: Color(0xFF68C3E7)),
                          ),
                          hSizedBox10,
                          ReadMoreText(
                            controller.posts[index].description ?? "",
                            textAlign: TextAlign.left,
                            style: style400S16.copyWith(color: Colors.white),
                            trimLines: 3,
                            trimMode: TrimMode.Line,
                            moreStyle:
                                style500S14.copyWith(color: Color(0xFFFFB86B)),
                            lessStyle:
                                style500S14.copyWith(color: Color(0xFFFFB86B)),
                            trimCollapsedText: 'Show more',
                            trimExpandedText: ' Show less',
                          ),

                          hSizedBox8,

                          // Timestamp
                          Text(
                            formatTimeAgo(controller.posts[index].updatedAt),
                            style: style400S12.copyWith(color: Colors.white60),
                          ),
                        ],
                      ),
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }
}
