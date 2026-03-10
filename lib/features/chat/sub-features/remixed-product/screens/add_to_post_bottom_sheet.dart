import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/local_storage_service.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/app_text_field.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/features/quotation-chat/models/analyze_dress_model.dart';
import 'package:vousvous/routes/app_pages.dart';

import '../../../../../core/constants/api_constants.dart';

class AddToPostBottomSheet extends StatefulWidget {
  final String? initialVisibility;
  final String imageUrl;

  const AddToPostBottomSheet({
    super.key,
    required this.imageUrl,
    this.initialVisibility,
  });

  @override
  State<AddToPostBottomSheet> createState() => _AddToPostBottomSheetState();
}

class _AddToPostBottomSheetState extends State<AddToPostBottomSheet> {
  late final RxString selectedVisibility;
  final RxBool loader = false.obs;
  final RxBool isAnalyzing = true.obs;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController typeController = TextEditingController();
  final TextEditingController colorController = TextEditingController();
  final TextEditingController materialController = TextEditingController();

  String productType = "";

  @override
  void initState() {
    super.initState();
    selectedVisibility = (widget.initialVisibility ?? 'public').obs;
    // Auto-analyze on init
    analyzeProduct();
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

  Future<void> analyzeProduct() async {
    try {
      isAnalyzing.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.analyzeProduct}", MethodType.post,
          baseUrlType: BaseUrl.ai,
          params: {
            "image_path": widget.imageUrl,
          });

      if (result.isSuccess) {
        var analyzeDressModel = AnalyzeDressModel.fromJson(result.data?.data);
        titleController.text = analyzeDressModel.analysis?.title ?? "";
        descriptionController.text =
            analyzeDressModel.analysis?.description ?? "";
        typeController.text = analyzeDressModel.analysis?.type ?? "";
        colorController.text = analyzeDressModel.analysis?.color ?? "";
        materialController.text = analyzeDressModel.analysis?.material ?? "";
        productType = analyzeDressModel.analysis?.type ?? "";
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isAnalyzing.value = false;
    }
  }

  Future<void> createProduct() async {
    if (titleController.text.trim().isEmpty) {
      toast("Please enter a title");
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      toast("Please enter a description");
      return;
    }

    try {
      loader.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.product}", MethodType.post,
          baseUrlType: BaseUrl.base,
          params: {
            'image': widget.imageUrl,
            'title': titleController.text.trim(),
            'type': typeController.text.trim(),
            'description': descriptionController.text.trim(),
            'color': colorController.text.trim(),
            'material': materialController.text.trim(),
            'isPrivate': selectedVisibility.value == "private",
          });

      if (result.isSuccess) {
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        Get.back();
        toast("Added As Post Successfully", type: ToastType.success);
        Get.toNamed(Routes.userProfile, arguments: {
          "userId": LocalStorageService.instance.userInfo.value.data?.id
        });
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
    return Container(
      child: SafeArea(
        top: false,
        child: Obx(() {
          if (isAnalyzing.value) {
            return SizedBox(
              height: 300,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const RotatingLoader(size: 40),
                    hSizedBox20,
                    Text(
                      "Analyzing your design...",
                      style: style600S16.copyWith(color: AppColors.whiteColor),
                    ),
                  ],
                ),
              ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              hSizedBox20,
              // Header
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    "Add to Post",
                    style: style700S16.copyWith(
                      color: AppColors.whiteColor,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              hSizedBox8,
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
                          Expanded(
                            flex: 2,
                            child: Container(
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
                                  imageUrl: widget.imageUrl,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          wSizedBox16,
                          // Visibility
                          Expanded(
                            flex: 3,
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
              // Post Button
              Obx(
                () => Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4)
                          .copyWith(bottom: 8),
                  child: AppButton(
                    onTap: createProduct,
                    isLoading: loader.value,
                    child: Text(
                      "Add to Post",
                      style: style700S16.copyWith(color: Colors.black),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
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
