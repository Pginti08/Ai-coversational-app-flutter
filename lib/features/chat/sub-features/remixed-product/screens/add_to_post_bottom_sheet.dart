import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  RxBool loader = false.obs;

  @override
  void initState() {
    super.initState();
    selectedVisibility = (widget.initialVisibility ?? '').obs;
  }

  Future<void> analyzeProduct() async {
    try {
      loader.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.analyzeProduct}", MethodType.post,
          baseUrlType: BaseUrl.chat,
          params: {
            "image_path": widget.imageUrl,
          });

      if (result.isSuccess) {
        var analyzeDressModel = AnalyzeDressModel.fromJson(result.data?.data);
        createProduct(
            image: widget.imageUrl,
            title: analyzeDressModel.analysis?.title ?? "",
            description: analyzeDressModel.analysis?.description ?? "",
            type: analyzeDressModel.analysis?.type ?? "");
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      loader.value = false;
    }
  }

  Future<void> createProduct(
      {required String image,
      required String title,
      required String type,
      required String description}) async {
    try {
      loader.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.product}", MethodType.post,
          baseUrlType: BaseUrl.base,
          params: {
            'image': image,
            'title': title,
            'type': type,
            'description': description,
            'isPrivate': selectedVisibility.value == "private" ? true : false,
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
                    analyzeProduct();
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
