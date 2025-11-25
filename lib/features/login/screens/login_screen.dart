import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_text_field.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/login/controller/login_controller.dart';
import 'package:vousvous/routes/app_pages.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginController controller = Get.put(LoginController());

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
                    "Login your account",
                    style: style400S16.copyWith(color: AppColors.textColor),
                  ),
                ),
                hSizedBox30,
                Obx(() => AppTextField(
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
                    )),
                // hSizedBox16,
                // Text(
                //   "Lorem Ipsum is simply dummy text of the printing nd typesetting industry. Lorem Ipsum has been the industry's",
                //   style: style400S12.copyWith(
                //     color: const Color(0xFF747474),
                //   ),
                // ),
                hSizedBox30,
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Don’t have an account? ",
                          style: style400S12.copyWith(
                              letterSpacing: 0.24,
                              color: const Color(0xFF747474)),
                        ),
                        TextSpan(
                          text: 'Sign up Here',
                          style: style400S12.copyWith(
                              decoration: TextDecoration.underline,
                              letterSpacing: 0.24,
                              color: AppColors.whiteColor),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Get.offNamed(Routes.signup);
                            },
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(),
                Obx(() => AppButton(
                      onTap: () {
                        controller.validateAndLogin();
                      },
                      text: "Continue",
                      isLoading: controller.isLoading.value,
                    )),
                hSizedBox24,
                RichText(
                  text: TextSpan(
                    style: style400S12.copyWith(
                      letterSpacing: 0.24,
                      color: const Color(0xFFCCCCCC),
                    ),
                    children: [
                      const TextSpan(text: "By signing in, you agree to our "),
                      TextSpan(
                        text: "Terms & Privacy Policy",
                        style: const TextStyle(
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            launchUrl(Uri.parse("https://google.com"),
                                mode: LaunchMode.externalApplication);
                          },
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
    );
  }
}
