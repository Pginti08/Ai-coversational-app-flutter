import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/features/orders-detail/models/order_detail_model.dart';

// ==================== HORIZONTAL PROGRESS BAR ====================
class ShippingProgressBarHorizontally extends StatelessWidget {
  final List<Tracking> tracking;
  final Color activeColor;
  final Color inactiveColor;
  final Color lineColor;

  const ShippingProgressBarHorizontally({
    Key? key,
    required this.tracking,
    this.activeColor = const Color(0xFF4FC3F7),
    this.inactiveColor = const Color(0xFF757575),
    this.lineColor = const Color(0xFF4FC3F7),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icons and connecting lines
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
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
        ),
        hSizedBox6,
        // Labels
        Row(
          children: [
            _buildStepLabel("ORDER PLACED", 1),
            _buildStepLabel("STITCHING", 2),
            _buildStepLabel("SHIPPED", 3),
            _buildStepLabel("OUT FOR DELIVERY", 4),
            _buildStepLabel("DELIVERED", 5),
          ],
        ),
      ],
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

    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: isActive ? lineColor : inactiveColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(1),
            ),
            child: isCurrentlyProgressing
                ? Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                        Color(0xFF68C3E7),
                        Color(0xFFFFB86B),
                        inactiveColor,
                        inactiveColor,
                      ]),
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

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: style700S10.copyWith(
            fontSize: 9,
            color: isActive ? activeColor : inactiveColor,
            letterSpacing: 0.80,
          ),
        ),
      ),
    );
  }
}
