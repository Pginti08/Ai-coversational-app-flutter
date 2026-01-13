import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/services/network_service.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/common_utils.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_network_image.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/features/quotation-chat/models/quotation_chat_history_model.dart';
import 'package:vousvous/routes/app_pages.dart';

class FinalQuotationCard extends StatelessWidget {
  FinalQuotationCard({
    super.key,
    required this.quotation,
    this.message,
    required this.updatedBySupport,
    this.onMessageUpdate, // Add callback
  });

  final UpdatedBySupport updatedBySupport;
  final CardDetail quotation;
  final Item? message;

  final Function(Item)? onMessageUpdate; // Add callback parameter

  final RxBool isLoading = false.obs;

  Future<void> addToCartApi(String quotationCardId) async {
    try {
      isLoading.value = true;

      var result = await NetworkClient.instance.callApi(
          "${ApiConstants.cart}", MethodType.post,
          baseUrlType: BaseUrl.base,
          params: {
            "quotationCardId": quotationCardId,
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

  Future<void> modificationRequest(
      String quotationCardId, String action) async {
    try {
      isLoading.value = true;

      var result = await NetworkClient.instance.callApi(
          "/quotations/$quotationCardId${ApiConstants.modificationRequest}",
          MethodType.patch,
          baseUrlType: BaseUrl.base,
          params: {"action": action, "reason": action});

      if (result.isSuccess) {
        // Update the message using the callback
        if (isNotNullOrEmpty(result.data?.data["data"])) {
          if (message != null && onMessageUpdate != null) {
            final updatedMessage = message!.copyWith(
              cardDetail: CardDetail.fromJson(result.data?.data["data"]),
              updatedBySupport: UpdatedBySupport(),
            );
            onMessageUpdate!(updatedMessage);
          }
        }
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
                  isNotNullOrEmpty(quotation.date)
                      ? DateFormat("dd-MMM-yyyy")
                          .format(quotation.date!)
                          .toUpperCase()
                      : "-",
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
                          _buildInfoRow('COLOR', quotation.color ?? '-',
                              updatedBySupport.color),
                          hSizedBox16,
                          // Material
                          _buildInfoRow('MATERIAL', quotation.material ?? '-',
                              updatedBySupport.material),
                          hSizedBox16,

                          // Size/Measurement
                          _buildInfoRow(
                              'SIZE/MEASUREMENT',
                              isNotNullOrEmpty(quotation.sizeMeasurement)
                                  ? quotation.sizeMeasurement!
                                  : isNotNullOrEmpty(quotation.bulkQuantities)
                                      ? bulkQuantitiesToReadableText(
                                          quotation.bulkQuantities)
                                      : "-",
                              "")
                        ],
                      ),
                    ),
                    wSizedBox10,
                    AppNetworkImage(
                      width: 85,
                      height: 130,
                      borderRadius: BorderRadius.circular(12),
                      imageUrl: quotation.dressImage ?? '',
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                hSizedBox16,

                // Special Requests
                _buildInfoRow(
                    'SPECIAL REQUESTS',
                    quotation.specialRequests ?? '-',
                    updatedBySupport.specialRequests),
                hSizedBox16,
                Row(
                  children: [
                    _buildInfoRow(
                      'QUANTITY',
                      isNotNullOrEmpty(quotation.quantity)
                          ? quotation.quantity.toString()
                          : "",
                      "",
                    ),
                    wSizedBox10,
                    if (isNotNullOrEmpty(quotation.price) &&
                        (quotation.price ?? 0) != 0)
                      _buildInfoRow(
                          'PRICE',
                          "${AssetConstants.rupeeSymbol}${quotation.price?.toStringAsFixed(0) ?? '-'}/pc",
                          ""),
                  ],
                ),
                hSizedBox24,
                // Place Order Button
                Obx(() => quotation.status == "MODIFICATION_REQUESTED"
                    ? isLoading.value
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height: 28,
                                width: 28,
                                child: CircularProgressIndicator(
                                  color: AppColors.secondaryColor,
                                ),
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: AppButton(
                                  text: "CANCEL",
                                  isOutlined: true,
                                  textColor: AppColors.whiteColor,
                                  onTap: () {
                                    modificationRequest(
                                        message?.id ?? "", "CANCEL");
                                  },
                                ),
                              ),
                              wSizedBox10,
                              Expanded(
                                child: AppButton(
                                  text: "ACCEPT",
                                  onTap: () {
                                    modificationRequest(
                                        message?.id ?? "", "ACCEPT");
                                  },
                                ),
                              )
                            ],
                          )
                    : AppButton(
                        text: quotation.status == "FINALIZED"
                            ? 'Add To Cart'
                            : quotation.status?.replaceAll("_", " "),
                        isDisabled: quotation.status != "FINALIZED",
                        onTap: () {
                          addToCartApi(message?.id ?? "");
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

  Widget _buildInfoRow(String label, String value, String? newValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: style700S10.copyWith(
            letterSpacing: 0.80,
            color: const Color(0xFF666666),
          ),
        ),
        Text(
          value,
          style: style400S14.copyWith(
            color: AppColors.whiteColor,
            letterSpacing: 0.28,
          ),
        ),
        if (isNotNullOrEmpty(newValue)) ...[
          Text(
            newValue!,
            style: style400S14.copyWith(
              color: Colors.amberAccent, // highlight new value
              letterSpacing: 0.28,
            ),
          ),
          Text(
            "(Requested Update)",
            style: style700S10.copyWith(
              color: Colors.orange,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ],
    );
  }
}
