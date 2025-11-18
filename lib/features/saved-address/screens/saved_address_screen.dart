import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_loader.dart';
import 'package:ai_fashion/core/widgets/blur_bottom_sheet.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:ai_fashion/core/widgets/common_dialog.dart';
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
      isBottomSafeArea: false,
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
                    Text('Saved addresses'.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: style700S16.copyWith(
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
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10)
                        .copyWith(bottom: 0),
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
                          child: AddAddressBottomSheet(
                            onSuccess: () {
                              controller.getSavedAddress();
                            },
                          ),
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
                    hSizedBox10,
                    Expanded(
                      child: Obx(
                        () => controller.isLoading.value
                            ? Center(
                                child: RotatingLoader(),
                              )
                            : (controller.savedAddressModel.value.data
                                            ?.length ??
                                        0) ==
                                    0
                                ? Center(
                                    child: Text(
                                      "Empty Saved Address",
                                      style: style400S14,
                                    ),
                                  )
                                : ListView.separated(
                                    padding: EdgeInsets.symmetric(vertical: 20),
                                    itemCount: controller.savedAddressModel
                                            .value.data?.length ??
                                        0,
                                    separatorBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Divider(
                                          color: AppColors.grey2Color,
                                        ),
                                      );
                                    },
                                    itemBuilder: (context, index) {
                                      var address = controller
                                          .savedAddressModel.value.data?[index];
                                      return Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  address?.name ?? "",
                                                  style: style500S18.copyWith(
                                                    letterSpacing: 0.36,
                                                    color:
                                                        const Color(0xFFEFEFEF),
                                                  ),
                                                ),
                                                Text(
                                                  address?.address ?? "",
                                                  style: style400S14.copyWith(
                                                    letterSpacing: 0.28,
                                                    color:
                                                        const Color(0xFFCCCCCC),
                                                  ),
                                                ),
                                                hSizedBox10,
                                                Text.rich(
                                                  TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: 'Mobile Number:',
                                                        style: style400S14
                                                            .copyWith(
                                                          letterSpacing: 0.28,
                                                          color: const Color(
                                                              0xFF666666),
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text:
                                                            ' ${address?.mobile ?? ""}',
                                                        style: style400S14
                                                            .copyWith(
                                                          letterSpacing: 0.28,
                                                          color: const Color(
                                                              0xFFCCCCCC),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              CommonContainer(
                                                  isCircle: true,
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  onTap: () {
                                                    BlurBottomSheet()
                                                        .show<void>(
                                                      height: MediaQuery.sizeOf(
                                                                  context)
                                                              .height *
                                                          0.9,
                                                      context: context,
                                                      borderColor: AppColors
                                                          .whiteColor
                                                          .withAlpha(
                                                        40,
                                                      ),
                                                      backgroundColor: AppColors
                                                          .scaffoldColor,
                                                      barrierColor: AppColors
                                                          .blackColor
                                                          .withAlpha(100),
                                                      blurStrength: 30,
                                                      isCloseButton: true,
                                                      child:
                                                          AddAddressBottomSheet(
                                                        isEdit: true,
                                                        savedAddress: address,
                                                        onSuccess: () {
                                                          controller
                                                              .getSavedAddress();
                                                        },
                                                      ),
                                                    );
                                                  },
                                                  child: SvgPicture.asset(
                                                      AssetConstants.edit)),
                                              hSizedBox10,
                                              CommonContainer(
                                                  isCircle: true,
                                                  borderGradientColors:
                                                      AppColors
                                                          .glassBorderGradient,
                                                  padding: EdgeInsets.all(8),
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  onTap: () {
                                                    commonDialog(
                                                        title:
                                                            "Delete Saved Address?",
                                                        description:
                                                            "Are you sure you want to delete this permanently?",
                                                        successButtonTitle:
                                                            "Delete",
                                                        cancelButtonTitle:
                                                            "Cancel",
                                                        onSuccess: () {
                                                          controller
                                                              .deleteSavedAddress(
                                                                  address?.id);
                                                        },
                                                        isLoading: controller
                                                            .isLoading2);
                                                  },
                                                  child: SvgPicture.asset(
                                                      AssetConstants.remove))
                                            ],
                                          )
                                        ],
                                      );
                                    },
                                  ),
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
