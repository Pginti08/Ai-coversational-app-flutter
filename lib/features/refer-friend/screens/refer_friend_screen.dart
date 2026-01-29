import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/app_toast.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/refer-friend/controller/refer_friend_controller.dart';

class ReferFriendScreen extends StatelessWidget {
  ReferFriendScreen({super.key});

  final ReferFriendController controller = Get.put(ReferFriendController());

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isBottomSafeArea: false,
      body: Column(
        children: [
          // Header
          _buildHeader(),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
                  hSizedBox30,

                  // Illustration/Icon
                  _buildIllustration(),

                  hSizedBox24,

                  // // Title
                  // Text(
                  //   'Share & Earn',
                  //   style: style700S24.copyWith(color: AppColors.whiteColor),
                  // ),

                  hSizedBox8,

                  // Subtitle
                  Text(
                    'Invite your friends to VousVous and earn rewards when they sign up!',
                    textAlign: TextAlign.center,
                    style: style400S14.copyWith(
                      color: AppColors.whiteColor.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                  ),

                  hSizedBox30,

                  // Referral Code Card
                  _buildReferralCodeCard(),

                  hSizedBox20,

                  // Action Buttons
                  _buildActionButtons(),

                  hSizedBox30,

                  // How It Works Section
                  _buildHowItWorks(),

                  hSizedBox30,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Refer a Friend'.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: style700S14.copyWith(
                      letterSpacing: 0.96, color: Color(0xFFCCCCCC))),
            ],
          ),
          Positioned(
            left: 0,
            child: IconButton(
              onPressed: () {
                Get.back();
              },
              icon: SvgPicture.asset(
                AssetConstants.backward,
                height: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      width: 100,
      height: 100,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.colorGradient,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 1,
          ),
        ],
      ),
      child: SvgPicture.asset(
        AssetConstants.gift,
        colorFilter: ColorFilter.mode(
          AppColors.blackColor,
          BlendMode.srcIn,
        ),
      ),
    );
  }

  Widget _buildReferralCodeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.whiteColor.withValues(alpha: 0.15),
            AppColors.whiteColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Your Referral Code',
            style: style400S14.copyWith(
              color: AppColors.whiteColor.withValues(alpha: 0.7),
            ),
          ),
          hSizedBox12,
          Obx(() => Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.blackColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      controller.referralCode.value,
                      style: style700S28.copyWith(
                        color: AppColors.whiteColor,
                        letterSpacing: 4,
                      ),
                    ),
                    wSizedBox16,
                    GestureDetector(
                      onTap: controller.copyReferralCode,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.copy_rounded,
                          color: AppColors.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Share Button
        AppButton(
          onTap: controller.shareReferralLink,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.share_rounded, color: AppColors.blackColor, size: 22),
              wSizedBox8,
              Text(
                'Share Referral Link',
                style: style700S16.copyWith(color: AppColors.blackColor),
              ),
            ],
          ),
        ),

        hSizedBox12,

        // Copy Link Button
        AppButton(
          onTap: () async {
            await Clipboard.setData(
              ClipboardData(text: controller.referralLink),
            );
            HapticFeedback.mediumImpact();
            toast(
              'Referral link copied to clipboard',
              type: ToastType.success,
            );
          },
          isOutlined: true,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.link_rounded, color: AppColors.whiteColor, size: 22),
              wSizedBox8,
              Text(
                'Copy Referral Link',
                style: style700S16.copyWith(color: AppColors.whiteColor),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHowItWorks() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.whiteColor.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works',
            style: style700S16.copyWith(color: AppColors.whiteColor),
          ),
          hSizedBox16,
          _buildStep(
            number: '1',
            title: 'Share Your Code',
            description: 'Share your unique referral code with friends',
          ),
          hSizedBox12,
          _buildStep(
            number: '2',
            title: 'Friend Signs Up',
            description:
                'Your friend downloads the app and signs up using your code',
          ),
          hSizedBox12,
          // NOTE: Step 3 removed as per latest UX requirement
        ],
      ),
    );
  }

  Widget _buildStep({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28.w,
          height: 28.w,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.colorGradient,
            ),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: style700S14.copyWith(color: AppColors.blackColor),
          ),
        ),
        wSizedBox12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: style600S14.copyWith(color: AppColors.whiteColor),
              ),
              hSizedBox4,
              Text(
                description,
                style: style400S12.copyWith(
                  color: AppColors.whiteColor.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
