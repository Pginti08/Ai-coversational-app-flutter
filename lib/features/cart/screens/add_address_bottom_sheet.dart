import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_text_field.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';

class AddAddressBottomSheet extends StatelessWidget {
  const AddAddressBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
          .copyWith(bottom: 0),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Text(
                  "Add new Address".toUpperCase(),
                  style: style700S12.copyWith(
                      letterSpacing: 0.96, color: Color(0xFFCCCCCC)),
                ),
                hSizedBox12,
                AppTextField(
                  label: "Name".toUpperCase(),
                  isRequired: true,
                  hint: "Enter Name",
                  isGradientBorder: true,
                  fillColor: AppColors.whiteColor.withAlpha(12),
                  hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                ),
                hSizedBox24,
                AppTextField(
                  label: "Mobile Number".toUpperCase(),
                  isRequired: true,
                  hint: "Enter Mobile Number",
                  isGradientBorder: true,
                  fillColor: AppColors.whiteColor.withAlpha(12),
                  hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                ),
                hSizedBox24,
                AppTextField(
                  label: "Pincode".toUpperCase(),
                  isRequired: true,
                  hint: "Enter Pincode",
                  isGradientBorder: true,
                  fillColor: AppColors.whiteColor.withAlpha(12),
                  hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                ),
                hSizedBox24,
                AppTextField(
                  label: "Address".toUpperCase(),
                  isRequired: true,
                  hint: "Enter Address",
                  isGradientBorder: true,
                  fillColor: AppColors.whiteColor.withAlpha(12),
                  hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                ),
                hSizedBox24,
                AppTextField(
                  label: "City".toUpperCase(),
                  isRequired: true,
                  hint: "Enter City",
                  isGradientBorder: true,
                  fillColor: AppColors.whiteColor.withAlpha(12),
                  hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                  readOnly: true,
                  suffixIcon: Transform.rotate(
                      angle: 3.14159,
                      child: SvgPicture.asset(
                        AssetConstants.backward,
                        height: 24,
                      )),
                ),
                hSizedBox24,
                AppTextField(
                  label: "State".toUpperCase(),
                  isRequired: true,
                  hint: "Enter State",
                  isGradientBorder: true,
                  fillColor: AppColors.whiteColor.withAlpha(12),
                  hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                  readOnly: true,
                  suffixIcon: Transform.rotate(
                      angle: 3.14159,
                      child: SvgPicture.asset(
                        AssetConstants.backward,
                        height: 24,
                      )),
                ),
                hSizedBox10,
              ],
            ),
          ),
          KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
            return isKeyboardVisible
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SafeArea(
                      top: false,
                      child: AppButton(
                        onTap: () {},
                        text: "Save Address",
                        textColor: AppColors.whiteColor,
                        backgroundColor: AppColors.whiteColor.withAlpha(12),
                        gradientBorderColors: AppColors.glassBorderGradient,
                      ),
                    ),
                  );
          })
        ],
      ),
    );
  }
}
