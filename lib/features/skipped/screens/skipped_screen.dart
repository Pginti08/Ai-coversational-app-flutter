import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/animated_heart_button.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/core/widgets/shimmer_utils.dart';
import 'package:vousvous/features/skipped/controller/skipped_controller.dart';

class SkippedScreen extends StatelessWidget {
  SkippedScreen({super.key});
  final SkippedController controller = Get.put(SkippedController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        isBottomEffect: false,
        isBottomSafeArea: false,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12)
                  .copyWith(top: Platform.isAndroid ? 6 : 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Skipped',
                      textAlign: TextAlign.center,
                      style: style700S28.copyWith(color: AppColors.textColor)),
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: SvgPicture.asset(AssetConstants.closeIcon),
                  )
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                return controller.isLoading.value
                    ? GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 0.65,
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12),
                        itemCount: 10,
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics()
                            .applyTo(const BouncingScrollPhysics()),
                        itemBuilder: (context, index) {
                          return shimmer(
                            child: shimmerContainer(
                                borderRadius: 12, width: Get.width),
                          );
                        },
                      )
                    : (controller.skipProductsList.isEmpty)
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                  AssetConstants.previous,
                                  height: 80,
                                  color: AppColors.textColor.withOpacity(0.3),
                                ),
                                hSizedBox20,
                                Text(
                                  'No skipped outfits yet',
                                  style: style500S16.copyWith(
                                    color: AppColors.textColor.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView(
                            padding: EdgeInsets.only(bottom: 16),
                            controller: controller.scrollController,
                            physics: const AlwaysScrollableScrollPhysics()
                                .applyTo(const BouncingScrollPhysics()),
                            children: [
                                GridView.builder(
                                  shrinkWrap: true,
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 0.65,
                                          crossAxisCount: 2,
                                          mainAxisSpacing: 12,
                                          crossAxisSpacing: 12),
                                  itemCount: controller.skipProductsList.length,
                                  itemBuilder: (context, index) {
                                    return Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.white.withAlpha(10),
                                              strokeAlign:
                                                  BorderSide.strokeAlignOutside,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: AppNetworkImage(
                                              imageUrl: controller
                                                      .skipProductsList[index]
                                                      .image ??
                                                  "",
                                              fit: BoxFit.cover,
                                              isOpenImageViewer: true,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 10,
                                          right: 10,
                                          child: AnimatedHeartButton(
                                            key: ValueKey(
                                                'heart_${controller.skipProductsList[index].id}'),
                                            onLiked: () {
                                              controller.likedProduct(controller
                                                  .skipProductsList[index].id);
                                            },
                                          ),
                                        )
                                      ],
                                    );
                                  },
                                ),
                                if (controller.paginationLoading.value)
                                  Padding(
                                    padding: EdgeInsets.all(8.w),
                                    child: Center(
                                      child: RotatingLoader(
                                        size: 30,
                                      ),
                                    ),
                                  ),
                              ]);
              }),
            ),
          ],
        ));
  }
}
