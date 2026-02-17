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
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/checkout/controller/checkout_controller.dart';
import 'package:vousvous/features/checkout/widgets/address_selection_sheet.dart';
import 'package:vousvous/features/saved-address/models/saved_address_model.dart';

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
                    icon: SvgPicture.asset(
                      AssetConstants.backward,
                      height: 24,
                    ),
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
                      hSizedBox10,

                      // Shipping Address Section
                      _buildSectionHeader("SHIPPING ADDRESS"),
                      hSizedBox12,
                      _buildSelectedAddressView(
                        context: context,
                        title: "Shipping Address",
                        address: controller.selectedAddress.value,
                        onTap: () => _showAddressSelectionSheet(
                          context,
                          controller.selectedAddress.value,
                          (address) =>
                              controller.selectShippingAddress(address),
                        ),
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

                      // Billing Address Section (only show if different)
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
                            _buildSelectedAddressView(
                              context: context,
                              title: "Billing Address",
                              address: controller.selectedBillingAddress.value,
                              onTap: () => _showAddressSelectionSheet(
                                context,
                                controller.selectedBillingAddress.value,
                                (address) =>
                                    controller.selectBillingAddress(address),
                              ),
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

  Widget _buildSelectedAddressView({
    required BuildContext context,
    required String title,
    required SavedAddress? address,
    required VoidCallback onTap,
  }) {
    if (address == null) {
      return CommonContainer(
        onTap: onTap,
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        borderRadius: 16,
        backgroundColor: Colors.white.withAlpha(20),
        child: Row(
          children: [
            Icon(Icons.add, color: AppColors.whiteColor),
            wSizedBox12,
            Text(
              "Select $title",
              style: style500S16.copyWith(color: AppColors.whiteColor),
            ),
            Spacer(),
            Icon(Icons.arrow_forward_ios,
                size: 16, color: AppColors.whiteColor),
          ],
        ),
      );
    }

    return CommonContainer(
      padding: EdgeInsets.all(16),
      borderRadius: 16,
      backgroundColor: Colors.white.withAlpha(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                address.name ?? "",
                style: style600S16.copyWith(
                  letterSpacing: 0.32,
                  color: const Color(0xFFEFEFEF),
                ),
              ),
              CommonContainer(
                onTap: onTap,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                borderRadius: 20,
                backgroundColor: AppColors.primaryColor.withAlpha(30),
                child: Text(
                  "Change",
                  style: style600S12.copyWith(color: AppColors.primaryColor),
                ),
              ),
            ],
          ),
          hSizedBox8,
          Text(
            address.address ?? "",
            style: style400S14.copyWith(
              letterSpacing: 0.28,
              color: const Color(0xFFCCCCCC),
            ),
          ),
          hSizedBox8,
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Mobile: ',
                  style: style400S14.copyWith(
                    letterSpacing: 0.28,
                    color: const Color(0xFF666666),
                  ),
                ),
                TextSpan(
                  text: address.mobile ?? "",
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
    );
  }

  void _showAddressSelectionSheet(
    BuildContext context,
    SavedAddress? currentSelected,
    Function(SavedAddress) onSelect,
  ) {
    BlurBottomSheet().show<void>(
      height: MediaQuery.sizeOf(context).height * 0.8,
      context: context,
      borderColor: AppColors.whiteColor.withAlpha(40),
      backgroundColor: AppColors.scaffoldColor.withAlpha(240),
      barrierColor: AppColors.blackColor.withAlpha(100),
      blurStrength: 10,
      isCloseButton: true,
      child: AddressSelectionSheet(
        selectedAddress: currentSelected,
        onSelect: onSelect,
      ),
    );
  }

  Widget _buildQuotationBottomBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSummaryRow(
                  "Total Price",
                  "${AssetConstants.rupeeSymbol}${controller.quotationTotalAmount.toFormattedPrice()}",
                  isBold: true,
                ),
                hSizedBox8,
                _buildSummaryRow(
                  "Pay Now (50%)",
                  "${AssetConstants.rupeeSymbol}${controller.upfrontAmount.toFormattedPrice()}",
                  valueColor: const Color(0xFF68C3E7),
                ),
                hSizedBox8,
                _buildSummaryRow(
                  "Pay on Delivery (50%)",
                  "${AssetConstants.rupeeSymbol}${controller.remainingAmount.toFormattedPrice()}",
                  valueColor: const Color(0xFFCCCCCC),
                ),

                hSizedBox8,
                Row(
                  children: [
                    Text(
                      "Credits Required Now",
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
                          "${controller.upfrontCredits.toFormattedCoins()} ",
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
                          "Pay ${controller.upfrontCredits.toFormattedCoins()} ",
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
}
