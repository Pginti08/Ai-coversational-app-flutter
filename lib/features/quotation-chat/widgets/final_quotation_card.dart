import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:ai_fashion/features/quotation-chat/models/final_quotation_model.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FinalQuotationCard extends StatelessWidget {
  FinalQuotationCard({
    super.key,
    required this.quotation,
  });

  final FinalQuotationModel quotation;

  RxBool isLoading = false.obs;

  Future<void> addToCartApi(String quotationId) async {
    try {
      isLoading.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.cart}", MethodType.post,
          baseUrlType: BaseUrl.base,
          params: {
            "quotationId": quotationId,
          });

      if (result.isSuccess) {
        Get.until((route) => Get.currentRoute == Routes.home);
        Get.toNamed(Routes.cart);
      } else {
        toast(result.error.toString());
      }
    } catch (e) {
      toast(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      backgroundColor: AppColors.whiteColor.withAlpha(20),
      borderGradientColors: AppColors.glassBorderGradient,
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUOTATION NUMBER',
                      style: style700S10.copyWith(
                        letterSpacing: 0.80,
                        color: Color(0xFF666666),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      quotation.quotationNumber ?? '-',
                      style: style700S12.copyWith(
                        letterSpacing: 0.96,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  (quotation.date ?? '').toUpperCase(),
                  style: style700S10.copyWith(
                    letterSpacing: 0.80,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
          Divider(
            color: AppColors.greyBorderColor,
            thickness: 0.75,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Color
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildInfoRow('COLOR', quotation.color ?? '-'),
                          hSizedBox16,
                          // Material
                          _buildInfoRow('MATERIAL', quotation.material ?? '-'),
                          hSizedBox16,

                          // Size/Measurement
                          _buildInfoRow(
                              'SIZE/MEASUREMENT',
                              isJson(quotation.measurements)
                                  ? jsonToReadableText(
                                      quotation.measurements ?? "")
                                  : (quotation.measurements ?? "")),
                        ],
                      ),
                    ),
                    wSizedBox10,
                    AppNetworkImage(
                      width: 85,
                      height: 130,
                      borderRadius: BorderRadius.circular(12),
                      imageUrl: quotation.dressImageUrl ?? '',
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                hSizedBox16,

                // Special Requests
                _buildInfoRow(
                    'SPECIAL REQUESTS', quotation.specialRequests ?? '-'),
                hSizedBox16,
                Row(
                  children: [
                    _buildInfoRow('QUANTITY', quotation.quantity ?? '-'),
                    wSizedBox10,
                    _buildInfoRow(
                      'PRICE',
                      quotation.price ?? '-',
                    ),
                  ],
                ),
                hSizedBox24,
                // Place Order Button
                Obx(() => AppButton(
                      text: quotation.status?.toLowerCase() == "finalized"
                          ? 'Add To Cart'
                          : "Pending",
                      isDisabled:
                          quotation.status?.toLowerCase() != "finalized",
                      onTap: () {
                        addToCartApi(quotation.quotationId ?? "");
                      },
                      isLoading: isLoading.value,
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: style700S10.copyWith(
            letterSpacing: 0.80,
            color: Color(0xFF666666),
          ),
        ),
        Text(
          value,
          style: style400S14.copyWith(
              color: AppColors.whiteColor, letterSpacing: 0.28),
        ),
      ],
    );
  }
}
