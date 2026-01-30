import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_text_field.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/wallet/sub-feature/buy_credit/controller/buy_credit_controller.dart';

class BuyCreditScreen extends StatelessWidget {
  BuyCreditScreen({super.key});
  final BuyCreditController controller = Get.put(BuyCreditController());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: CustomScaffold(
        isBottomEffect: false,
        isBottomSafeArea: false,
        resizeToAvoidBottomInset: false,
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6).copyWith(bottom: 0),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Buy Credit'.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: style700S14.copyWith(
                              color: Color(0xFFCCCCCC), letterSpacing: 0.96)),
                    ],
                  ),
                  Positioned(
                    left: 0,
                    child: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: SvgPicture.asset(AssetConstants.backward),
                    ),
                  ),
                ],
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      hSizedBox16,
                      // Info Container
                      CommonContainer(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        borderRadius: 100,
                        borderGradientColors: AppColors.glassBorderGradient,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              AssetConstants.infoCircle,
                              width: 25,
                              color: const Color(0xFFFCE301),
                            ),
                            wSizedBox8,
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "0.01 CREDITS = ${AssetConstants.rupeeSymbol}1",
                                    textAlign: TextAlign.start,
                                    style: style700S12.copyWith(
                                      letterSpacing: 0.96,
                                      color: const Color(0xFFFFB86B),
                                    ),
                                  ),
                                  hSizedBox4,
                                  Text(
                                    "Credits are calculated automatically",
                                    textAlign: TextAlign.start,
                                    style: style400S14.copyWith(
                                        letterSpacing: 0.28,
                                        color: Color(0xFFCCCCCC)),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      hSizedBox24,
                      // Buy Credits Container
                      CommonContainer(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        borderRadius: 20,
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        borderGradientColors: AppColors.glassBorderGradient,
                        backgroundColor: AppColors.grey2Color.withAlpha(120),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Buy Credits",
                              style: style700S16.copyWith(
                                letterSpacing: 0.32,
                              ),
                            ),
                            hSizedBox16,
                            AppTextField(
                              autofocus: true,
                              hint: "Enter Credits",
                              controller: controller.creditController,
                              isGradientBorder: true,
                              fillColor: AppColors.whiteColor.withAlpha(8),
                              hintStyle: style400S16.copyWith(
                                  color: Color(0xFF444444)),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d*\.?\d{0,2}')),
                              ],
                            ),
                            hSizedBox20,
                            // Amount Payable Section
                            Obx(() => CommonContainer(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 14),
                                  borderRadius: 12,
                                  backgroundColor:
                                      AppColors.whiteColor.withAlpha(10),
                                  borderGradientColors:
                                      AppColors.glassBorderGradient,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Amount Payable",
                                        style: style400S16.copyWith(
                                            letterSpacing: 0.32,
                                            color: Color(0xFFCCCCCC)),
                                      ),
                                      Text(
                                        "${AssetConstants.rupeeSymbol}${controller.payableAmount.value.toStringAsFixed(2)}",
                                        style: style700S20.copyWith(
                                          letterSpacing: 0.4,
                                          color: const Color(0xFFFFB86B),
                                        ),
                                      ),
                                    ],
                                  ),
                                )),
                            hSizedBox20,
                            // Pay Now Button
                            Obx(() => AppButton(
                                  width: MediaQuery.sizeOf(context).width * 0.5,
                                  onTap: controller.onPayNow,
                                  text: "Pay Now",
                                  loaderColor: AppColors.blackColor,
                                  isLoading: controller.isLoading.value,
                                )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
                        .copyWith(bottom: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      AssetConstants.secure,
                    ),
                    wSizedBox4,
                    Flexible(
                      child: Text(
                        "Secure payments. Credits added instantly",
                        textAlign: TextAlign.center,
                        style: style400S12.copyWith(
                            letterSpacing: 0.24, color: Color(0xFFCCCCCC)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
