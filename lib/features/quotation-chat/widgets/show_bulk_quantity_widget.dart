import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/blur_bottom_sheet.dart';
import 'package:vousvous/features/quotation-chat/controller/quotation_chat_controller.dart';
import 'package:vousvous/features/quotation-chat/widgets/bulk_quantity_bottom_sheet.dart';

class ShowBulkQuantityWidget extends StatelessWidget {
  const ShowBulkQuantityWidget({
    super.key,
    required this.quotationChatController,
  });
  final QuotationChatController quotationChatController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: AppButton(
            isOutlined: true,
            isGradientBorder: true,
            gradientBorderColors: AppColors.colorGradient,
            onTap: () {
              BlurBottomSheet().show<void>(
                child: BulkQuantityBottomSheet(
                  sizes: ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
                  onSave: (values) {
                    Get.back();
                    quotationChatController.sendMessage(message: values);
                  },
                ),
                height: MediaQuery.sizeOf(context).height * 0.65,
                context: context,
                borderColor: AppColors.whiteColor.withAlpha(40),
                backgroundColor: AppColors.scaffoldColor.withAlpha(200),
                barrierColor: AppColors.blackColor.withAlpha(50),
                blurStrength: 30,
                isCloseButton: true,
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AssetConstants.magicpen,
                  color: AppColors.whiteColor,
                  width: 20,
                ),
                wSizedBox8,
                Text(
                  "Fill Bulk Quantity Form",
                  style: style700S16.copyWith(color: Color(0xFFCCCCCC)),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
