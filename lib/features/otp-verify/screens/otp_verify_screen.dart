import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_pin_put_field.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/otp-verify/controller/otp_verify_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class OtpVerify extends StatefulWidget {
  const OtpVerify({super.key});

  @override
  State<OtpVerify> createState() => _OtpVerifyState();
}

class _OtpVerifyState extends State<OtpVerify> {
  final OtpVerifyController controller = Get.put(OtpVerifyController());

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
                child: Obx(() {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: controller.isOtpVerified.value
                        ? Column(
                            key: const ValueKey("successView"),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(AssetConstants.success),
                              hSizedBox50,
                              Text(
                                "Success!",
                                style: style700S22.copyWith(
                                    color: AppColors.textColor),
                              ),
                              hSizedBox12,
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "Congratulations! You have been successfully authenticated",
                                  textAlign: TextAlign.center,
                                  style: style500S18.copyWith(
                                      color: AppColors.greyTextColor),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            key: const ValueKey("otpView"),
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              hSizedBox50,
                              hSizedBox50,
                              Text(
                                "we’ve sent a 4-digit code ",
                                style: style600S20.copyWith(
                                    color: AppColors.textColor),
                              ),
                              Text(
                                "to your phone number +91 98** *****",
                                style: style300S12.copyWith(
                                    color: AppColors.textColor),
                              ),
                              hSizedBox30,
                              AppPinputField(
                                length: 4,
                                size: 60,
                                keyboardType: TextInputType.number,
                                autofocus: true,
                                onChanged: (value) {},
                              ),
                              hSizedBox30,
                              Obx(
                                () => controller.secondsRemaining.value == 0
                                    ? InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          controller.startResendTimer();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 8,
                                          ),
                                          child: Text(
                                            "Resend Code",
                                            style: style400S14.copyWith(
                                              letterSpacing: 0.28,
                                              color: AppColors.primaryColor,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Resend OTP in ",
                                              style: style400S14.copyWith(
                                                letterSpacing: 0.28,
                                                color: AppColors.hintTextColor,
                                              ),
                                            ),
                                            Text(
                                              "${(controller.secondsRemaining.value ~/ 60).toString().padLeft(2, '0')}:${(controller.secondsRemaining.value % 60).toString().padLeft(2, '0')}",
                                              style: style400S14.copyWith(
                                                letterSpacing: 0.28,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                              ),
                              Spacer(),
                              AppButton(
                                onTap: () {
                                  controller
                                      .verifyOtp(); // 🔥 switch to success
                                },
                                text: "Verify OTP",
                              ),
                            ],
                          ),
                  );
                }))));
  }
}
