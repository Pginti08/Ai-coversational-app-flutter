import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/skipped/controller/skipped_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

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
              padding: const EdgeInsets.all(12),
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
                if (controller.skippedOutfitCardModels.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AssetConstants.heart,
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
                  );
                }

                return GridView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      childAspectRatio: 0.65,
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12),
                  itemCount: controller.skippedOutfitCardModels.length,
                  itemBuilder: (context, index) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withAlpha(10),
                          strokeAlign: BorderSide.strokeAlignOutside,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppNetworkImage(
                          imageUrl: controller
                                  .skippedOutfitCardModels[index].imageUrl ??
                              "",
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ));
  }
}
