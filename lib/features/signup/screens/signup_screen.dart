import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_text_field.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/signup/controller/signup_controller.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final SignupController controller = Get.put(SignupController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: CustomScaffold(
          resizeToAvoidBottomInset: false,
          body: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                hSizedBox10,
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Welcome",
                    style: style700S32.copyWith(color: AppColors.textColor),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Sign up to your account",
                    style: style400S16.copyWith(color: AppColors.textColor),
                  ),
                ),
                hSizedBox30,
                AppTextField(
                  hint: "Name",
                  controller: controller.nameController,
                  isGradientBorder: true,
                  fillColor: AppColors.whiteColor.withAlpha(8),
                  hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                  errorText: controller.nameError.value.isEmpty
                      ? null
                      : controller.nameError.value,
                  onChanged: (value) {
                    if (controller.nameError.value.isNotEmpty) {
                      controller.nameError.value = '';
                    }
                  },
                ),
                hSizedBox16,
                AppTextField(
                  hint: "Mobile number",
                  controller: controller.mobileNoController,
                  isGradientBorder: true,
                  fillColor: AppColors.whiteColor.withAlpha(8),
                  hintStyle: style400S16.copyWith(color: Color(0xFF444444)),
                  maxLength: 10,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  prefixIcon: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('🇮🇳+91', style: style400S16),
                      hSizedBox2,
                    ],
                  ),
                  errorText: controller.mobileError.value.isEmpty
                      ? null
                      : controller.mobileError.value,
                  onChanged: (value) {
                    if (controller.mobileError.value.isNotEmpty) {
                      controller.mobileError.value = '';
                    }
                  },
                ),
                Text(
                  "Lorem Ipsum is simply dummy text of the printing nd typesetting industry. Lorem Ipsum has been the industry's",
                  style: style400S12.copyWith(
                    color: const Color(0xFF747474),
                  ),
                ),
                hSizedBox30,
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Already have an account? ",
                          style: style400S12.copyWith(
                              letterSpacing: 0.24,
                              color: const Color(0xFF747474)),
                        ),
                        TextSpan(
                          text: 'Login Here',
                          style: style400S12.copyWith(
                              decoration: TextDecoration.underline,
                              letterSpacing: 0.24,
                              color: AppColors.whiteColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.offNamed(Routes.login);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Obx(() => AppButton(
                      onTap: () {
                        controller.validateAndSignUp();
                      },
                      text: "Continue",
                      isLoading: controller.isLoading.value,
                    )),
                hSizedBox24,
                Text(
                  "By signing in, you agree to our Terms & Privacy Policy.",
                  style: style400S12.copyWith(
                      letterSpacing: 0.24, color: Color(0xFFCCCCCC)),
                )
              ],
            ),
          )),
    );
  }
}
