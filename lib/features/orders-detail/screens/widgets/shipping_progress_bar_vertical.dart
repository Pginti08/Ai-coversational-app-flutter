import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/features/orders-detail/models/order_detail_model.dart';

// ==================== VERTICAL PROGRESS BAR ====================
class ShippingProgressBarVertically extends StatelessWidget {
  final List<Tracking> tracking;
  final Color activeColor;
  final Color inactiveColor;
  final Color lineColor;

  const ShippingProgressBarVertically({
    Key? key,
    required this.tracking,
    this.activeColor = const Color(0xFF4FC3F7),
    this.inactiveColor = const Color(0xFF757575),
    this.lineColor = const Color(0xFF4FC3F7),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icons and connecting lines
          Column(
            children: [
              _buildStepIcon(AssetConstants.box, 1),
              _buildConnectingLine(1),
              _buildStepIcon(AssetConstants.scissor, 2),
              _buildConnectingLine(2),
              _buildStepIcon(AssetConstants.truckTime, 3),
              _buildConnectingLine(3),
              _buildStepIcon(AssetConstants.truckTick, 4),
              _buildConnectingLine(4),
              _buildStepIcon(AssetConstants.boxTick, 5),
            ],
          ),
          wSizedBox6,
          // Labels
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStepLabel("ORDER PLACED", 1),
              _buildStepLabel("STITCHING", 2),
              _buildStepLabel("SHIPPED", 3),
              _buildStepLabel("OUT FOR DELIVERY", 4),
              _buildStepLabel("DELIVERED", 5),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(String icon, int step) {
    final isActive = step <= tracking.length;

    return SvgPicture.asset(
      icon,
      color: isActive ? activeColor : inactiveColor,
      height: 20,
    );
  }

  Widget _buildConnectingLine(int step) {
    final isActive = step < tracking.length;
    final isCurrentlyProgressing = step == tracking.length;

    return SizedBox(
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? lineColor : inactiveColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1),
            ),
            child: isCurrentlyProgressing
                ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF68C3E7),
                          Color(0xFFFFB86B),
                          inactiveColor,
                          inactiveColor,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  )
                : null,
          ),
          if (isCurrentlyProgressing)
            Container(
              height: 10,
              width: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFB86B),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildStepLabel(String label, int step) {
    final isActive = step <= tracking.length;
    final timestamp = tracking
        .firstWhereOrNull((e) => e.status == getOrderStatusFromLabel(label))
        ?.updatedAt
        ?.toLocal();

    return SizedBox(
      height: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: style700S14.copyWith(
              color: isActive ? activeColor : inactiveColor,
              letterSpacing: 0.80,
            ),
          ),
          if (timestamp != null) ...[
            hSizedBox12,
            Text(
              DateFormat("dd MMM yyyy, hh:mm a")
                  .format(timestamp)
                  .toUpperCase(),
              style: style400S10.copyWith(
                color: AppColors.whiteColor,
                letterSpacing: 0.80,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String getOrderStatusFromLabel(String label) {
    switch (label) {
      case 'ORDER PLACED':
        return 'ORDER_PLACED';

      case 'STITCHING':
        return "PROCESSING";

      case 'SHIPPED':
        return "SHIPPED";
      case 'OUT FOR DELIVERY':
        return "OUT_FOR_DELIVERY";

      case 'DELIVERED':
        return "DELIVERED";

      default:
        return "";
    }
  }
}
