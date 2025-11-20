import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';

class ShippingProgressBar extends StatelessWidget {
  final int currentStep;
  final Color activeColor;
  final Color inactiveColor;
  final Color lineColor;

  const ShippingProgressBar({
    Key? key,
    this.currentStep = 2, // Default to step 2 (Stitching Your Dress)
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
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Row(
            children: [
              _buildStepIcon(AssetConstants.box, 1),
              _buildConnectingLine(1),
              _buildStepIcon(AssetConstants.scissor, 2),
              _buildConnectingLine(2),
              _buildStepIcon(AssetConstants.truck, 3),
              _buildConnectingLine(3),
              _buildStepIcon(AssetConstants.boxTick, 4),
            ],
          ),
        ),
        hSizedBox10,
        // Labels
        Row(
          children: [
            _buildStepLabel("ORDER PLACED", 1),
            _buildStepLabel("STITCHING YOUR DRESS", 2),
            _buildStepLabel("OUT FOR DELIVERY", 3),
            _buildStepLabel("DELIVERED", 4),
          ],
        ),
      ],
    );
  }

  Widget _buildStepIcon(String icon, int step) {
    final isActive = step <= currentStep;

    return SvgPicture.asset(
      icon,
      color: isActive ? activeColor : inactiveColor,
    );
  }

  Widget _buildConnectingLine(int step) {
    final isActive = step < currentStep;
    final isCurrentlyProgressing = step == currentStep;

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
                  shape: BoxShape.circle, color: Color(0xFFFFB86B)),
            )
        ],
      ),
    );
  }

  Widget _buildStepLabel(String label, int step) {
    final isActive = step <= currentStep;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: style700S10.copyWith(
              color: isActive ? activeColor : inactiveColor,
              letterSpacing: 0.80),
        ),
      ),
    );
  }
}

// Example usage widget
class ShippingProgressExample extends StatefulWidget {
  @override
  _ShippingProgressExampleState createState() =>
      _ShippingProgressExampleState();
}

class _ShippingProgressExampleState extends State<ShippingProgressExample> {
  int currentStep = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Shipping Progress'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ShippingProgressBar(currentStep: currentStep),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: currentStep > 1
                      ? () => setState(() => currentStep--)
                      : null,
                  child: Text('Previous'),
                ),
                ElevatedButton(
                  onPressed: currentStep < 4
                      ? () => setState(() => currentStep++)
                      : null,
                  child: Text('Next'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Current Step: $currentStep',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
