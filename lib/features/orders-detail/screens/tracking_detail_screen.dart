import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/orders-detail/controller/order_detail_controller.dart';
import 'package:vousvous/features/orders-detail/screens/widgets/shipping_progress_bar_vertical.dart';

class TrackingDetailScreen extends StatelessWidget {
  TrackingDetailScreen({super.key});
  final OrderDetailController controller = Get.find<OrderDetailController>();

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        isBottomEffect: false,
        isBottomSafeArea: false,
        body: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Get.back();
                  },
                  icon: SvgPicture.asset(AssetConstants.backward),
                ),
                Text('Tracking Details',
                    textAlign: TextAlign.center,
                    style:
                        style500S20.copyWith(color: AppColors.whiteTextColor)),
              ],
            ),
            Expanded(
                child: ShippingProgressBarVertically(
              tracking: controller.orderDetailModel.value.tracking ?? [],
              activeColor: Color(0xFF4FC3F7),
              inactiveColor: Color(0xFF757575),
            ))
          ],
        ));
  }
}
