import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/features/checkout/controller/checkout_controller.dart';
import 'package:vousvous/features/saved-address/models/saved_address_model.dart';
import 'package:vousvous/features/saved-address/screens/add_address_bottom_sheet.dart';

class AddressSelectionSheet extends StatelessWidget {
  final SavedAddress? selectedAddress;
  final Function(SavedAddress) onSelect;

  AddressSelectionSheet({
    super.key,
    this.selectedAddress,
    required this.onSelect,
  });

  final CheckoutController controller = Get.find<CheckoutController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
          child: Text(
            "Select Address".toUpperCase(),
            style: style700S12.copyWith(
              letterSpacing: 0.96,
              color: const Color(0xFFCCCCCC),
            ),
          ),
        ),
        hSizedBox20,

        // Address List
        Expanded(
          child: Obx(() {
            final addresses = controller.savedAddressModel.value.data ?? [];

            if (addresses.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "No saved addresses found.",
                      style: style400S14.copyWith(color: Color(0xFF999999)),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(16),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => hSizedBox12,
              itemBuilder: (context, index) {
                final address = addresses[index];
                final isSelected = selectedAddress?.id == address.id;

                return CommonContainer(
                  padding: EdgeInsets.all(10),
                  borderRadius: 16,
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  borderGradientColors:
                      isSelected ? AppColors.colorGradient : null,
                  gradientColors: isSelected
                      ? [
                          Color(0xFF68C3E7).withAlpha(30),
                          Color(0xFFFFB86B).withAlpha(30),
                        ]
                      : [
                          Colors.white.withAlpha(10),
                          Colors.white.withAlpha(15),
                        ],
                  onTap: () {
                    onSelect(address);
                    Get.back();
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Radio Icon
                      Container(
                        height: 20,
                        width: 20,
                        margin: EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Color(0xFF68C3E7)
                                : Color(0xFF666666),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: isSelected
                            ? Container(
                                height: 10,
                                width: 10,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF68C3E7),
                                ),
                              )
                            : null,
                      ),
                      wSizedBox12,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address.name ?? "",
                              style: style500S16.copyWith(
                                color: const Color(0xFFEFEFEF),
                              ),
                            ),
                            hSizedBox4,
                            Text(
                              address.address ?? "",
                              style: style400S14.copyWith(
                                color: const Color(0xFFCCCCCC),
                              ),
                            ),
                            hSizedBox4,
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Mobile: ',
                                    style: style400S14.copyWith(
                                      color: const Color(0xFF666666),
                                    ),
                                  ),
                                  TextSpan(
                                    text: address.mobile ?? "",
                                    style: style400S14.copyWith(
                                      color: const Color(0xFFCCCCCC),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Edit Button
                      GestureDetector(
                        onTap: () {
                          Get.back(); // Close selection sheet
                          _showEditAddressSheet(context, address);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: SvgPicture.asset(
                            AssetConstants.edit,
                            color: Color(0xFF999999),
                            height: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),

        // Add New Address Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            isOutlined: true,
            isGradientBorder: true,
            onTap: () {
              Get.back(); // Close selection sheet
              _showAddAddressSheet(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(AssetConstants.add, width: 20),
                wSizedBox8,
                Text(
                  "Add New Address",
                  style: style700S16.copyWith(color: Color(0xFFCCCCCC)),
                )
              ],
            ),
          ),
        ),
        hSizedBox10,
      ],
    );
  }

  void _showAddAddressSheet(BuildContext context) {
    BlurBottomSheet().show<void>(
      height: MediaQuery.sizeOf(context).height * 0.9,
      context: context,
      borderColor: AppColors.whiteColor.withAlpha(40),
      backgroundColor: AppColors.scaffoldColor.withAlpha(200),
      barrierColor: AppColors.blackColor.withAlpha(100),
      blurStrength: 10,
      isCloseButton: true,
      child: AddAddressBottomSheet(
        onSuccess: () => controller.getSavedAddress(),
      ),
    );
  }

  void _showEditAddressSheet(BuildContext context, SavedAddress address) {
    BlurBottomSheet().show<void>(
      height: MediaQuery.sizeOf(context).height * 0.9,
      context: context,
      borderColor: AppColors.whiteColor.withAlpha(40),
      backgroundColor: AppColors.scaffoldColor,
      barrierColor: AppColors.blackColor.withAlpha(100),
      blurStrength: 10,
      isCloseButton: true,
      child: AddAddressBottomSheet(
        isEdit: true,
        savedAddress: address,
        onSuccess: () => controller.getSavedAddress(),
      ),
    );
  }
}
