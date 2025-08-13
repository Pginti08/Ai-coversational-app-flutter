import 'dart:io';

import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/chat/controller/chat_controller.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/route_manager.dart';

class PastConversation extends StatefulWidget {
  const PastConversation({required this.controller, super.key});
  final ChatController controller;

  @override
  State<PastConversation> createState() => _PastConversationState();
}

class _PastConversationState extends State<PastConversation> {
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      scaffoldColor: Color(0xFF121212),
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text(
                            "Conversations".toUpperCase(),
                            style: style700S16.copyWith(
                              letterSpacing: 1.28,
                              color: Color(0xFFCCCCCC),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: 20,
                  separatorBuilder: (context, index) {
                    return hSizedBox10;
                  },
                  itemBuilder: (context, index) {
                    return InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      onTap: () {},
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        child: Container(
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Chic sundress with vibrant floral patterns, perfect for a seaside gathering.",
                                      overflow: TextOverflow.ellipsis,
                                      style: style400S16.copyWith(
                                        color: Color(0xFFE0E0E0),
                                        letterSpacing: 0.32,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              hSizedBox12,
              Divider(
                thickness: 0.5,
                color: AppColors.dividerColor,
              ),
              hSizedBox12,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Column(
                  children: [
                    AppButton(
                      onTap: () {},
                      isOutlined: true,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AssetConstants.edit),
                          wSizedBox6,
                          Text("New Chat", style: style700S16),
                        ],
                      ),
                    ),
                    hSizedBox12,
                    AppButton(
                      onTap: () {
                        Get.toNamed(Routes.myDesigns);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AssetConstants.colorfilter),
                          wSizedBox6,
                          Text("My Designs",
                              style: style700S16.copyWith(
                                  color: AppColors.blackColor)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (Platform.isAndroid) hSizedBox10,
            ],
          ),
        ),
      ),
    );
  }
}
