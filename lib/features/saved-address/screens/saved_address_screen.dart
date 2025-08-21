import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/blur_bottom_sheet.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/saved-address/controller/saved_address_controller.dart';
import 'package:ai_fashion/features/saved-address/screens/add_address_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SavedAddressScreen extends StatelessWidget {
  SavedAddressScreen({super.key});
  final SavedAddressController controller = Get.put(SavedAddressController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isBottomEffect: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Saved addresses'.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: style700S12.copyWith(
                            letterSpacing: 0.96, color: Color(0xFFCCCCCC))),
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
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  children: [
                    hSizedBox18,
                    AppButton(
                      isOutlined: true,
                      isGradientBorder: true,
                      onTap: () {
                        BlurBottomSheet().show<void>(
                          height: MediaQuery.sizeOf(context).height * 0.9,
                          context: context,
                          borderColor: AppColors.whiteColor.withAlpha(
                            40,
                          ),
                          backgroundColor: AppColors.scaffoldColor,
                          barrierColor: AppColors.blackColor.withAlpha(100),
                          blurStrength: 30,
                          isCloseButton: true,
                          child: AddAddressBottomSheet(),
                        );
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AssetConstants.add,
                            width: 20,
                          ),
                          wSizedBox8,
                          Text(
                            "Add New Address",
                            style:
                                style700S16.copyWith(color: Color(0xFFCCCCCC)),
                          )
                        ],
                      ),
                    ),
                    hSizedBox30,
                    Expanded(
                      child: ListView.separated(
                        itemCount: 2,
                        separatorBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Divider(
                              color: AppColors.grey2Color,
                            ),
                          );
                        },
                        itemBuilder: (context, index) {
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Maya Patel",
                                      style: style500S18.copyWith(
                                        letterSpacing: 0.36,
                                        color: const Color(0xFFEFEFEF),
                                      ),
                                    ),
                                    Text(
                                      "45 Maple Street, Bangalore, 560001,",
                                      style: style400S14.copyWith(
                                        letterSpacing: 0.28,
                                        color: const Color(0xFFCCCCCC),
                                      ),
                                    ),
                                    hSizedBox10,
                                    Text.rich(
                                      TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Mobile Number:',
                                            style: style400S14.copyWith(
                                              letterSpacing: 0.28,
                                              color: const Color(0xFF666666),
                                            ),
                                          ),
                                          TextSpan(
                                            text: ' +91 98765 43210',
                                            style: style400S14.copyWith(
                                              letterSpacing: 0.28,
                                              color: const Color(0xFFCCCCCC),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              CommonContainer(
                                  isCircle: true,
                                  backgroundColor: Colors.transparent,
                                  onTap: () {
                                    BlurBottomSheet().show<void>(
                                      height:
                                          MediaQuery.sizeOf(context).height *
                                              0.9,
                                      context: context,
                                      borderColor:
                                          AppColors.whiteColor.withAlpha(
                                        40,
                                      ),
                                      backgroundColor: AppColors.scaffoldColor,
                                      barrierColor:
                                          AppColors.blackColor.withAlpha(100),
                                      blurStrength: 30,
                                      isCloseButton: true,
                                      child: AddAddressBottomSheet(),
                                    );
                                  },
                                  child: SvgPicture.asset(AssetConstants.edit))
                            ],
                          );
                        },
                      ),
                    ),
                    hSizedBox10,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
