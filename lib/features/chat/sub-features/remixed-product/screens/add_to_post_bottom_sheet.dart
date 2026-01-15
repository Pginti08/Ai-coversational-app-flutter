import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/features/quotation-chat/models/analyze_dress_model.dart';

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
    super.dispose();
  }

  Future<void> analyzeProduct() async {
    try {
      isAnalyzing.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.analyzeProduct}", MethodType.post,
          baseUrlType: BaseUrl.chat,
          params: {
            "image_path": widget.imageUrl,
          });

      if (result.isSuccess) {
        var analyzeDressModel = AnalyzeDressModel.fromJson(result.data?.data);
        titleController.text = analyzeDressModel.analysis?.title ?? "";
        descriptionController.text =
            analyzeDressModel.analysis?.description ?? "";
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
            'type': productType,
            'description': descriptionController.text.trim(),
            'isPrivate': selectedVisibility.value == "private",
          });

      if (result.isSuccess) {
        if (Get.isBottomSheetOpen ?? false) {
          Get.back();
        }
        toast("Added As Post Successfully", type: ToastType.success);
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
      child: Obx(() {
        if (isAnalyzing.value) {
          return Center(
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
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              hSizedBox8,

              // Image Preview
              Center(
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withAlpha(100),
                    ),
                    color: AppColors.blackColor.withAlpha(50),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AppNetworkImage(
                      imageUrl: widget.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              hSizedBox20,

              // Title Field
              Text(
                "Title",
                style: style600S14.copyWith(color: AppColors.whiteColor),
              ),
              hSizedBox8,
              CommonContainer(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                borderRadius: 12,
                borderGradientColors: [
                  AppColors.grey2Color,
                  AppColors.grey2Color,
                ],
                child: TextField(
                  controller: titleController,
                  style: style500S14.copyWith(color: AppColors.whiteColor),
                  maxLines: 2,
                  minLines: 1,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter title",
                    hintStyle: style400S14.copyWith(
                      color: AppColors.greyTextColor,
                    ),
                  ),
                ),
              ),

              hSizedBox16,

              // Description Field
              Text(
                "Description",
                style: style600S14.copyWith(color: AppColors.whiteColor),
              ),
              hSizedBox8,
              CommonContainer(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                borderRadius: 12,
                borderGradientColors: [
                  AppColors.grey2Color,
                  AppColors.grey2Color,
                ],
                child: TextField(
                  controller: descriptionController,
                  style: style500S14.copyWith(color: AppColors.whiteColor),
                  maxLines: 4,
                  minLines: 3,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter description",
                    hintStyle: style400S14.copyWith(
                      color: AppColors.greyTextColor,
                    ),
                  ),
                ),
              ),

              hSizedBox16,

              // Visibility Section
              Text(
                "Visibility",
                style: style600S14.copyWith(color: AppColors.whiteColor),
              ),
              hSizedBox8,

              Row(
                children: [
                  Expanded(
                    child: _visibilityTile(
                      label: "Public",
                      icon: AssetConstants.public,
                      value: "public",
                    ),
                  ),
                  wSizedBox12,
                  Expanded(
                    child: _visibilityTile(
                      label: "Private",
                      icon: AssetConstants.private,
                      value: "private",
                    ),
                  ),
                ],
              ),

              hSizedBox20,

              // Post Button
              Obx(
                () => AppButton(
                  onTap: createProduct,
                  isLoading: loader.value,
                  child: Text(
                    "Post",
                    style: style700S16.copyWith(color: Colors.black),
                  ),
                ),
              ),

              hSizedBox20,
            ],
          ),
        );
      }),
    );
  }

  Widget _visibilityTile({
    required String label,
    required String icon,
    required String value,
  }) {
    final isSelected = selectedVisibility.value == value;

    return CommonContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      borderRadius: 12,
      borderGradientColors: isSelected
          ? AppColors.colorGradient
          : [
              AppColors.grey2Color,
              AppColors.grey2Color,
            ],
      onTap: () => selectedVisibility.value = value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(icon, color: Colors.white, width: 20),
          wSizedBox6,
          Text(
            label,
            style: style600S14.copyWith(
              color: isSelected ? Colors.white : AppColors.greyTextColor,
            ),
          ),
        ],
      ),
    );
  }
}
