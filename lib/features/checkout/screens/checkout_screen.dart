import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/extensions.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_loader.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/custom_radio.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/checkout/controller/checkout_controller.dart';
import 'package:vousvous/features/saved-address/models/saved_address_model.dart';
import 'package:vousvous/features/saved-address/screens/add_address_bottom_sheet.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});

  final CheckoutController controller = Get.put(CheckoutController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isEffect3: true,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          children: [
            // Header
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Checkout'.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: style700S14.copyWith(
                        letterSpacing: 0.96,
                        color: Color(0xFFCCCCCC),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: SvgPicture.asset(AssetConstants.backward),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: RotatingLoader());
                }

                return SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      hSizedBox10,
                      // Add New Address Button
                      AppButton(
                        isOutlined: true,
                        isGradientBorder: true,
                        onTap: () => _showAddAddressSheet(context),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(AssetConstants.add, width: 20),
                            wSizedBox8,
                            Text(
                              "Add New Address",
                              style: style700S16.copyWith(
                                  color: Color(0xFFCCCCCC)),
                            )
                          ],
                        ),
                      ),
                      hSizedBox24,

                      // Shipping Address Section
                      _buildSectionHeader("SHIPPING ADDRESS"),
                      hSizedBox12,
                      _buildAddressList(
                        context: context,
                        selectedAddress: controller.selectedAddress,
                        onSelect: controller.selectShippingAddress,
                      ),

                      hSizedBox24,
                      // Billing Same as Shipping Checkbox
                      Obx(() => GestureDetector(
                            onTap: () => controller.toggleBillingSameAsShipping(
                                !controller.billingSameAsShipping.value),
                            child: Row(
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color:
                                          controller.billingSameAsShipping.value
                                              ? Color(0xFF68C3E7)
                                              : Color(0xFF666666),
                                      width: 1,
                                    ),
                                    color:
                                        controller.billingSameAsShipping.value
                                            ? Color(0xFF68C3E7).withAlpha(30)
                                            : Colors.transparent,
                                  ),
                                  child: controller.billingSameAsShipping.value
                                      ? Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Color(0xFF68C3E7),
                                        )
                                      : null,
                                ),
                                wSizedBox6,
                                Text(
                                  "Billing address same as shipping",
                                  style: style400S14.copyWith(
                                    color: Color(0xFFCCCCCC),
                                    letterSpacing: 0.28,
                                  ),
                                ),
                              ],
                            ),
                          )),

                      // Billing Address List (only show if different)
                      Obx(() {
                        if (controller.billingSameAsShipping.value) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            hSizedBox24,
                            _buildSectionHeader("BILLING ADDRESS"),
                            hSizedBox12,
                            _buildAddressList(
                              context: context,
                              selectedAddress:
                                  controller.selectedBillingAddress,
                              onSelect: controller.selectBillingAddress,
                            ),
                          ],
                        );
                      }),

                      hSizedBox30,
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildQuotationBottomBar(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: style700S12.copyWith(
        letterSpacing: 0.96,
        color: Color(0xFF999999),
      ),
    );
  }

  Widget _buildAddressList({
    required BuildContext context,
    required Rxn<SavedAddress> selectedAddress,
    required Function(SavedAddress?) onSelect,
  }) {
    return Obx(() {
      final addresses = controller.savedAddressModel.value.data ?? [];

      if (addresses.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text(
            "No saved addresses. Add a new address.",
            style: style400S14.copyWith(color: Color(0xFF999999)),
          ),
        );
      }

      return Column(
        children: addresses.map((address) {
          final isSelected = selectedAddress.value == address;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: CommonContainer(
              padding: EdgeInsets.all(10),
              borderRadius: 16,
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              borderGradientColors: isSelected ? AppColors.colorGradient : null,
              gradientColors: isSelected
                  ? [
                      Color(0xFF68C3E7).withAlpha(30),
                      Color(0xFFFFB86B).withAlpha(30),
                    ]
                  : null,
              child: CustomRadio<SavedAddress?>(
                value: address,
                groupValue: selectedAddress.value,
                onChanged: onSelect,
                titleWidget: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            address.name ?? "",
                            style: style500S18.copyWith(
                              letterSpacing: 0.36,
                              color: const Color(0xFFEFEFEF),
                            ),
                          ),
                          Text(
                            address.address ?? "",
                            style: style400S14.copyWith(
                              letterSpacing: 0.28,
                              color: const Color(0xFFCCCCCC),
                            ),
                          ),
                          hSizedBox4,
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
                                  text: ' ${address.mobile ?? ""}',
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
                    Padding(
                      padding: const EdgeInsets.all(4),
                      child: CommonContainer(
                        isCircle: true,
                        backgroundColor: Colors.transparent,
                        onTap: () => _showEditAddressSheet(context, address),
                        child: SvgPicture.asset(AssetConstants.edit),
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildQuotationBottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(thickness: 0.5, color: AppColors.grey2Color),
                hSizedBox6,
                _buildSummaryRow("Quantity", "${controller.quotationQuantity}"),
                hSizedBox8,
                _buildSummaryRow(
                  "Unit Price",
                  "${AssetConstants.rupeeSymbol}${controller.quotation?.price?.toFormattedPrice() ?? "0"}",
                ),
                hSizedBox8,
                _buildSummaryRow(
                  "Total",
                  "${AssetConstants.rupeeSymbol}${controller.quotationTotalAmount.toFormattedPrice()}",
                  isBold: true,
                ),
                hSizedBox8,
                hSizedBox8,
                Row(
                  children: [
                    Text(
                      "Credits Required",
                      style: style400S16.copyWith(
                        letterSpacing: 0.32,
                        color: Color(0xFF666666),
                      ),
                    ),
                    wSizedBox10,
                    Expanded(
                      child: DottedLine(
                        dashLength: 3,
                        dashGapLength: 2,
                        dashColor: Colors.white.withAlpha(40),
                      ),
                    ),
                    wSizedBox10,
                    Row(
                      children: [
                        Text(
                          "${controller.creditsNeeded.toFormattedCoins()} ",
                          style: style400S14.copyWith(
                            letterSpacing: 0.28,
                            color: const Color(0xFF68C3E7),
                          ),
                        ),
                        Image.asset(
                          AssetConstants.vousvousCoin,
                          width: 14,
                          height: 14,
                        ),
                      ],
                    ),
                  ],
                ),
                hSizedBox8,
                // Show wallet balance
                hSizedBox8,
                // Show wallet balance
                Row(
                  children: [
                    Text(
                      "Wallet Balance",
                      style: style400S16.copyWith(
                        letterSpacing: 0.32,
                        color: Color(0xFF666666),
                      ),
                    ),
                    wSizedBox10,
                    Expanded(
                      child: DottedLine(
                        dashLength: 3,
                        dashGapLength: 2,
                        dashColor: Colors.white.withAlpha(40),
                      ),
                    ),
                    wSizedBox10,
                    controller.isLoadingBalance.value
                        ? Text(
                            "Loading...",
                            style: style400S14.copyWith(
                              letterSpacing: 0.28,
                              color: Color(0xFFCCCCCC),
                            ),
                          )
                        : Row(
                            children: [
                              Text(
                                "${controller.walletBalance.value.toFormattedCoins()} ",
                                style: style400S14.copyWith(
                                  letterSpacing: 0.28,
                                  color: controller.hasSufficientBalance
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFFFF5252),
                                ),
                              ),
                              Image.asset(
                                AssetConstants.vousvousCoin,
                                width: 14,
                                height: 14,
                              ),
                            ],
                          ),
                  ],
                ),
                Divider(color: AppColors.grey2Color),
                hSizedBox6,
                // Show different button based on balance
                if (!controller.hasSufficientBalance &&
                    !controller.isLoadingBalance.value) ...[
                  // Insufficient balance - show add credits button
                  AppButton(
                    onTap: controller.navigateToBuyCredits,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Add ${controller.creditsDeficit.toFormattedCoins()} ",
                          style: style700S16.copyWith(
                            color: AppColors.whiteColor,
                          ),
                        ),
                        Image.asset(
                          AssetConstants.vousvousCoin,
                          width: 16,
                          height: 16,
                        ),
                      ],
                    ),
                    isOutlined: true,
                    isGradientBorder: true,
                  ),
                  hSizedBox10,
                  Text(
                    "Insufficient credits. Add credits to continue.",
                    style: style400S12.copyWith(
                      color: const Color(0xFFFF5252),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else ...[
                  // Sufficient balance - show pay button
                  AppButton(
                    onTap: controller.placeOrderApi,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Pay ${controller.creditsNeeded.toFormattedCoins()} ",
                          style: style700S16.copyWith(
                            color: AppColors.blackColor,
                          ),
                        ),
                        Image.asset(
                          AssetConstants.vousvousCoin,
                          width: 16,
                          height: 16,
                        ),
                      ],
                    ),
                    isLoading: controller.isLoading2.value ||
                        controller.isLoadingBalance.value,
                  ),
                ],
                hSizedBox10,
              ],
            )),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      children: [
        Text(
          label,
          style: (isBold ? style700S16 : style400S16).copyWith(
            letterSpacing: 0.32,
            color: isBold ? null : Color(0xFF666666),
          ),
        ),
        wSizedBox10,
        Expanded(
          child: DottedLine(
            dashLength: 3,
            dashGapLength: 2,
            dashColor: Colors.white.withAlpha(40),
          ),
        ),
        wSizedBox10,
        Text(
          value,
          style: (isBold ? style700S16 : style400S14).copyWith(
            letterSpacing: 0.28,
            color: valueColor ?? Color(0xFFCCCCCC),
          ),
        ),
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
