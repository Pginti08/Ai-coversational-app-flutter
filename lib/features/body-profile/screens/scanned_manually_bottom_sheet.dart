import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_text_field.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:flutter/material.dart';

class ScannedManuallyBottomSheet extends StatelessWidget {
  const ScannedManuallyBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            Text(
              "Body Profile".toUpperCase(),
              style: style700S12.copyWith(
                  letterSpacing: 0.96, color: Color(0xFFCCCCCC)),
            ),
            hSizedBox16,
            AppTextField(
              label: "Name".toUpperCase(),
              isRequired: true,
              hint: "Enter your name",
              isGradientBorder: true,
              fillColor: AppColors.whiteColor.withAlpha(12),
              hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
            ),
            hSizedBox24,
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Measurements".toUpperCase(),
                style: style700S12.copyWith(
                    letterSpacing: 0.96, color: Color(0xFFCCCCCC)),
              ),
            ),
            hSizedBox10,
            Expanded(
                child: ListView(
              padding: EdgeInsets.zero,
              children: [
                measurementsTextField(title: "Height", unit: "cm"),
                hSizedBox18,
                measurementsTextField(title: "Bust", unit: "cm"),
                hSizedBox18,
                measurementsTextField(title: "Waist", unit: "cm"),
                hSizedBox18,
                measurementsTextField(title: "Hips", unit: "cm"),
              ],
            )),
            hSizedBox10,
            AppButton(
              text: "Save Body Profile",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  CommonContainer measurementsTextField({
    required String title,
    required String unit,
  }) {
    return CommonContainer(
      padding: EdgeInsets.symmetric(horizontal: 14),
      backgroundColor: AppColors.whiteColor.withAlpha(12),
      borderGradientColors: AppColors.glassBorderGradient,
      borderRadius: 100,
      child: Row(
        children: [
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: style700S12.copyWith(
                  letterSpacing: 0.96, color: Color(0xFF666666)),
            ),
          ),
          SizedBox(
            width: 50,
            child: AppTextField(
              contentPadding: EdgeInsets.all(0),
              outsideMargin: EdgeInsets.symmetric(
                vertical: 10,
              ),
              textAlign: TextAlign.end,
              borderColor: Colors.transparent,
              controller: TextEditingController(
                text: "165",
              ),
              textStyle: style600S20.copyWith(
                  letterSpacing: 0.42, color: AppColors.whiteTextColor),
            ),
          ),
          Text(
            unit.toUpperCase(),
            style: style700S12.copyWith(
                fontSize: 10, letterSpacing: 0.80, color: Color(0xFF666666)),
          ),
        ],
      ),
    );
  }
}
