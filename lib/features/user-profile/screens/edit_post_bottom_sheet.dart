import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/app_text_field.dart';
import 'package:vousvous/features/home/models/product_list_model.dart';
import 'package:vousvous/features/user-profile/controller/posts_view_controller.dart';

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
  late TextEditingController typeController;
  late TextEditingController colorController;
  late TextEditingController materialController;
  late RxString selectedVisibility;
  final RxBool isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.product.title ?? "");
    descriptionController =
        TextEditingController(text: widget.product.description ?? "");
    typeController = TextEditingController(text: "");
    colorController = TextEditingController(text: "");
    materialController = TextEditingController(text: "");
    selectedVisibility =
        (widget.product.isPrivate ?? false ? "private" : "public").obs;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    typeController.dispose();
    colorController.dispose();
    materialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PostsViewController controller = Get.find<PostsViewController>();

    return Container(
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            hSizedBox20,
            // Header
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Edit Post",
                  style: style700S16.copyWith(
                    color: AppColors.whiteColor,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            hSizedBox16,
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 12,
                  right: 12,
                  top: 12,
                  bottom: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    hSizedBox10,
                    // Image and Visibility Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withAlpha(50),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: AppNetworkImage(
                              imageUrl: widget.product.image ?? "",
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        wSizedBox16,
                        // Visibility
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                "Visibility",
                                style: style600S14.copyWith(
                                  color: AppColors.whiteColor,
                                  fontSize: 13,
                                ),
                              ),
                              hSizedBox12,
                              _visibilityTile(
                                label: "Public",
                                icon: AssetConstants.public,
                                value: "public",
                              ),
                              hSizedBox10,
                              _visibilityTile(
                                label: "Private",
                                icon: AssetConstants.private,
                                value: "private",
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    hSizedBox24,

                    // Title Field
                    _buildLabel("Title"),
                    hSizedBox4,
                    AppTextField(
                      controller: titleController,
                      hint: "Enter title",
                      fillColor: AppColors.grey2Color.withAlpha(60),
                      borderColor: Colors.white.withAlpha(20),
                      borderRadius: 16,
                    ),

                    hSizedBox16,

                    // Description Field
                    _buildLabel("Description"),
                    hSizedBox4,
                    AppTextField(
                      controller: descriptionController,
                      hint: "Enter description",
                      maxLines: 3,
                      minLines: 2,
                      fillColor: AppColors.grey2Color.withAlpha(60),
                      borderColor: Colors.white.withAlpha(20),
                      borderRadius: 16,
                    ),

                    hSizedBox16,

                    // Type, Material in Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Type"),
                              hSizedBox4,
                              AppTextField(
                                controller: typeController,
                                hint: "Enter type",
                                fillColor: AppColors.grey2Color.withAlpha(60),
                                borderColor: Colors.white.withAlpha(20),
                                borderRadius: 16,
                              ),
                            ],
                          ),
                        ),
                        wSizedBox12,
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel("Material"),
                              hSizedBox4,
                              AppTextField(
                                controller: materialController,
                                hint: "Enter material",
                                fillColor: AppColors.grey2Color.withAlpha(60),
                                borderColor: Colors.white.withAlpha(20),
                                borderRadius: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    hSizedBox16,

                    _buildLabel("Color"),
                    hSizedBox4,
                    AppTextField(
                      controller: colorController,
                      hint: "Enter color",
                      fillColor: AppColors.grey2Color.withAlpha(60),
                      borderColor: Colors.white.withAlpha(20),
                      borderRadius: 16,
                    ),

                    hSizedBox24,
                  ],
                ),
              ),
            ),
            // Save Button
            Obx(
              () => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
                    .copyWith(bottom: 8),
                child: AppButton(
                  onTap: () async {
                    isLoading.value = true;
                    bool success = await controller.updatePost(
                      widget.product.id!,
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      isPrivate: selectedVisibility.value == "private",
                      type: typeController.text.trim(),
                      color: colorController.text.trim(),
                      material: materialController.text.trim(),
                    );
                    isLoading.value = false;
                    if (success) Get.back();
                  },
                  isLoading: isLoading.value,
                  child: Text(
                    "Save Changes",
                    style: style700S16.copyWith(color: Colors.black),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: style600S14.copyWith(
        color: AppColors.whiteColor.withAlpha(230),
        fontSize: 13,
      ),
    );
  }

  Widget _visibilityTile({
    required String label,
    required String icon,
    required String value,
  }) {
    final isSelected = selectedVisibility.value == value;

    return GestureDetector(
      onTap: () => selectedVisibility.value = value,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.whiteColor.withAlpha(20)
              : AppColors.grey2Color.withAlpha(40),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.whiteColor.withAlpha(100)
                : Colors.white.withAlpha(20),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              icon,
              color: isSelected ? Colors.white : AppColors.greyTextColor,
              width: 18,
            ),
            wSizedBox8,
            Text(
              label,
              style: style600S14.copyWith(
                color: isSelected ? Colors.white : AppColors.greyTextColor,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
