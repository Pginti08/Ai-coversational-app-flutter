import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/user-profile/controller/posts_view_controller.dart';
import 'package:vousvous/core/widgets/common_container.dart';

class EditPostBottomSheet extends StatefulWidget {
  final Product product;
  const EditPostBottomSheet({Key? key, required this.product})
      : super(key: key);

  @override
  State<EditPostBottomSheet> createState() => _EditPostBottomSheetState();
}

class _EditPostBottomSheetState extends State<EditPostBottomSheet> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late RxBool isPrivate;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.product.title ?? "");
    descriptionController =
        TextEditingController(text: widget.product.description ?? "");
    isPrivate = (widget.product.isPrivate ?? false).obs;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PostsViewController controller = Get.find<PostsViewController>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.scaffoldColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Edit Post",
                      style: style700S18.copyWith(color: Colors.white)),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.white60),
                  ),
                ],
              ),
            ),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Title",
                        style:
                            style600S14.copyWith(color: AppColors.whiteColor)),
                    hSizedBox8,
                    CommonContainer(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      borderRadius: 12,
                      borderGradientColors: [
                        AppColors.grey2Color,
                        AppColors.grey2Color
                      ],
                      child: TextField(
                        controller: titleController,
                        style:
                            style500S14.copyWith(color: AppColors.whiteColor),
                        maxLines: 2,
                        minLines: 1,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter title",
                          hintStyle: style400S14.copyWith(
                              color: AppColors.greyTextColor),
                        ),
                      ),
                    ),
                    hSizedBox16,
                    Text("Description",
                        style:
                            style600S14.copyWith(color: AppColors.whiteColor)),
                    hSizedBox8,
                    CommonContainer(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      borderRadius: 12,
                      borderGradientColors: [
                        AppColors.grey2Color,
                        AppColors.grey2Color
                      ],
                      child: TextField(
                        controller: descriptionController,
                        style:
                            style500S14.copyWith(color: AppColors.whiteColor),
                        maxLines: 6,
                        minLines: 3,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Enter description",
                          hintStyle: style400S14.copyWith(
                              color: AppColors.greyTextColor),
                        ),
                      ),
                    ),
                    hSizedBox16,
                    Obx(() => Row(
                          children: [
                            Text("Private Post",
                                style:
                                    style600S14.copyWith(color: Colors.white)),
                            const Spacer(),
                            Switch(
                              value: isPrivate.value,
                              onChanged: (val) => isPrivate.value = val,
                              activeColor: Colors.orange,
                              activeTrackColor: Colors.orange.withAlpha(100),
                            ),
                          ],
                        )),
                    hSizedBox24,
                    Obx(() => AppButton(
                          onTap: () async {
                            if (titleController.text.trim().isEmpty) {
                              Get.snackbar("Error", "Title cannot be empty",
                                  snackPosition: SnackPosition.BOTTOM,
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white);
                              return;
                            }
                            isLoading.value = true;
                            bool success = await controller.updatePost(
                              widget.product.id!,
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              isPrivate: isPrivate.value,
                            );
                            isLoading.value = false;
                            if (success) Get.back();
                          },
                          isLoading: isLoading.value,
                          child: Text("Save Changes",
                              style: style700S16.copyWith(color: Colors.black)),
                        )),
                    hSizedBox30,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
