import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/user-profile/controller/posts_view_controller.dart';
import 'package:vousvous/features/user-profile/controller/user_profile_controller.dart';

import '../../../../../core/constants/api_constants.dart';

class ChangeVisibilityBottomSheet extends StatefulWidget {
  final Product? product;

  const ChangeVisibilityBottomSheet({
    super.key,
    this.product,
  });

  @override
  State<ChangeVisibilityBottomSheet> createState() =>
      _ChangeVisibilityBottomSheetState();
}

class _ChangeVisibilityBottomSheetState
    extends State<ChangeVisibilityBottomSheet> {
  final RxString selectedVisibility = "".obs;

  RxBool loader = false.obs;

  @override
  void initState() {
    super.initState();
    if (widget.product?.isPrivate != null) {
      selectedVisibility.value = widget.product?.isPrivate == true
          ? "private"
          : widget.product?.isPrivate == false
              ? "public"
              : "";
    }
  }

  Future<void> changeVisibility() async {
    try {
      loader.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.product}/${widget.product?.id}", MethodType.patch,
          baseUrlType: BaseUrl.base,
          params: {
            'isPrivate': selectedVisibility.value == "private" ? true : false,
          });

      if (result.isSuccess) {
        toast(
          selectedVisibility.value == "private"
              ? "This Post is now private"
              : "This Post is now public",
          type: ToastType.success,
        );
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        // Update the product model with new visibility status
        final updatedProduct = widget.product?.copyWith(
          isPrivate: selectedVisibility.value == "private" ? true : false,
        );

        // Update PostsViewController list if it exists
        if (Get.isRegistered<PostsViewController>()) {
          final postsController = Get.find<PostsViewController>();
          final productIndex = postsController.posts.indexWhere(
            (p) => p.id == widget.product?.id,
          );
          if (productIndex != -1) {
            postsController.posts[productIndex] = updatedProduct!;
          }
        }
        // Update UserProfileController list if it exists
        if (Get.isRegistered<UserProfileController>()) {
          final postsController = Get.find<UserProfileController>();
          final productIndex = postsController.posts.indexWhere(
            (p) => p.id == widget.product?.id,
          );
          if (productIndex != -1) {
            postsController.posts[productIndex] = updatedProduct!;
          }
        }
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      loader.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            hSizedBox8,

            Text(
              "Post Visibility",
              style: style700S18.copyWith(color: Colors.white),
            ),
            hSizedBox20,

            // Only this part needs Obx
            Obx(
              () => Column(
                children: [
                  _visibilityTile(
                    label: "Public",
                    description: "Everyone can see",
                    icon: AssetConstants.public,
                    value: "public",
                  ),
                  hSizedBox12,
                  _visibilityTile(
                    label: "Private",
                    description: "Only you can see",
                    icon: AssetConstants.private,
                    value: "private",
                  ),
                ],
              ),
            ),

            Spacer(),

            Obx(
              () => AppButton(
                onTap: () {
                  if (isNotNullOrEmpty(selectedVisibility.value)) {
                    changeVisibility();
                  }
                },
                isLoading: loader.value,
                child: Text(
                  "Confirm",
                  style: style700S16.copyWith(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _visibilityTile({
    required String label,
    required String description,
    required String icon,
    required String value,
  }) {
    final isSelected = selectedVisibility.value == value;

    return CommonContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 18,

      // highlight ONLY when selected
      borderGradientColors: isSelected
          ? AppColors.colorGradient
          : [
              AppColors.grey2Color,
              AppColors.grey2Color,
            ],

      onTap: () => selectedVisibility.value = value,

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SvgPicture.asset(icon, color: Colors.white, width: 24),
          wSizedBox8,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: style700S16.copyWith(color: Colors.white)),
                hSizedBox4,
                Text(
                  description,
                  style: style400S12.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
