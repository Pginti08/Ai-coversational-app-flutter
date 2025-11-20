import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_text_field.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/common_container.dart';

class BulkQuantityBottomSheet extends StatefulWidget {
  const BulkQuantityBottomSheet({
    super.key,
    this.onSave,
    this.sizes,
  });

  final void Function(dynamic)? onSave;
  final List<String>? sizes;

  @override
  State<BulkQuantityBottomSheet> createState() =>
      _BulkQuantityBottomSheetState();
}

class _BulkQuantityBottomSheetState extends State<BulkQuantityBottomSheet> {
  late List<String> sizeList;
  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();

    // Default sizes if not provided
    sizeList = widget.sizes ?? ['XS', 'S', 'M', 'L', 'XL', 'XXL'];

    // Initialize controllers for each size
    controllers = {for (var size in sizeList) size: TextEditingController()};
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void validateAndSave() {
    // Create map with only non-zero quantities
    final Map<String, dynamic> quantitiesMap = {};

    for (var size in sizeList) {
      final value = controllers[size]!.text.trim();
      if (value.isNotEmpty) {
        final quantity = int.tryParse(value) ?? 0;
        if (quantity > 0) {
          quantitiesMap[size] = quantity;
        }
      }
    }

    // Check if at least one quantity is entered
    if (quantitiesMap.isEmpty) {
      toast('Please enter at least one quantity');
      return;
    }

    final String jsonString = json.encode(quantitiesMap);

    // Pass the JSON string via onSave callback
    widget.onSave?.call(jsonString);

    // Close bottom sheet
    if (Get.isBottomSheetOpen ?? false) {
      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color: Color(0xFFCCCCCC),
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  "Bulk Order - Specify Quantities".toUpperCase(),
                  style: style700S12.copyWith(
                    letterSpacing: 0.96,
                    color: Color(0xFFCCCCCC),
                  ),
                ),
              ],
            ),
            hSizedBox24,
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.zero,
                itemCount: sizeList.length,
                separatorBuilder: (context, index) => hSizedBox18,
                itemBuilder: (context, index) {
                  final size = sizeList[index];
                  return quantityTextField(
                    title: 'Size $size',
                    size: size,
                  );
                },
              ),
            ),
            hSizedBox10,
            KeyboardVisibilityBuilder(
              builder: (context, isKeyboardVisible) {
                return isKeyboardVisible
                    ? const SizedBox.shrink()
                    : Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: SafeArea(
                          top: false,
                          child: AppButton(
                            text: "Confirm Quantities",
                            onTap: () {
                              validateAndSave();
                            },
                          ),
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget quantityTextField({
    required String title,
    required String size,
  }) {
    final controller = controllers[size]!;
    final FocusNode focusNode = FocusNode();

    return GestureDetector(
      onTap: () {
        focusNode.requestFocus();
      },
      child: CommonContainer(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        backgroundColor: AppColors.whiteColor.withAlpha(12),
        borderGradientColors: AppColors.glassBorderGradient,
        borderRadius: 100,
        child: Row(
          children: [
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: style700S12.copyWith(
                  letterSpacing: 0.96,
                  color: const Color(0xFF666666),
                ),
              ),
            ),
            SizedBox(
              width: 60,
              child: AppTextField(
                focusNode: focusNode,
                contentPadding: EdgeInsets.all(0),
                outsideMargin: const EdgeInsets.symmetric(vertical: 10),
                textAlign: TextAlign.end,
                borderColor: Colors.transparent,
                controller: controller,
                hint: '0',
                hintStyle: style600S20.copyWith(
                  letterSpacing: 0.42,
                  color: AppColors.whiteTextColor.withOpacity(0.3),
                ),
                maxLength: 4,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                textStyle: style600S20.copyWith(
                  letterSpacing: 0.42,
                  color: AppColors.whiteTextColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
