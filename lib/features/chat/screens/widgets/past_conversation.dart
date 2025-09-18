import 'dart:io';

import 'package:ai_fashion/core/constants/api_constants.dart';
import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/services/network_service.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_button.dart';
import 'package:ai_fashion/core/widgets/app_toast.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/core/widgets/shimmer_utils.dart';
import 'package:ai_fashion/features/chat/controller/chat_controller.dart';
import 'package:ai_fashion/features/chat/models/sessions_model.dart';
import 'package:ai_fashion/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class PastConversation extends StatefulWidget {
  const PastConversation({required this.controller, super.key});
  final ChatController controller;

  @override
  State<PastConversation> createState() => _PastConversationState();
}

class _PastConversationState extends State<PastConversation> {
  final controller = Get.find<ChatController>();

  RxList<Session> sessionList = <Session>[].obs;
  RxBool loader = false.obs;
  RxBool hasLoadedOnce =
      false.obs; // Track if API has been called for current drawer opening

  Future getSessionList() async {
    if (hasLoadedOnce.value)
      return; // Don't load if already loaded for this drawer opening

    loader.value = true;
    hasLoadedOnce.value = true; // Mark as loaded

    var result = await NetworkClient.instance.callApi(
      "${ApiConstants.getSessionList}",
      MethodType.get,
      baseUrlType: BaseUrl.chat,
    );

    if (result.isSuccess) {
      loader.value = false;
      var sessionsModel = SessionsModel.fromJson(result.data?.data);
      sessionList.value = sessionsModel.data?.items ?? [];
    } else {
      loader.value = false;
      toast(result.error ?? "Failed to load data");
    }
  }

  @override
  void initState() {
    super.initState();
    // Don't call getSessionList here anymore

    // Listen to drawer open/close state
    ever(controller.isDrawerOpen, (bool isOpen) {
      if (isOpen && !hasLoadedOnce.value) {
        // Only call API when drawer opens and hasn't been loaded yet
        getSessionList();
      } else if (!isOpen) {
        // Reset the flag when drawer closes so it can load again next time it opens
        hasLoadedOnce.value = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      scaffoldColor: Color(0xFF121212),
      body: Container(
        child: Obx(
          () => loader.value
              ? ListView.separated(
                  shrinkWrap: true,
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  itemCount: 20,
                  separatorBuilder: (context, index) {
                    return hSizedBox20;
                  },
                  itemBuilder: (context, index) {
                    return shimmer(
                      color: const Color(0xFF222222),
                      child: shimmerContainer(
                        height: 40,
                        borderRadius: 6,
                      ),
                    );
                  },
                )
              : SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 10),
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
                          itemCount: sessionList.length,
                          separatorBuilder: (context, index) {
                            return hSizedBox10;
                          },
                          itemBuilder: (context, index) {
                            return InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: () {
                                controller
                                    .changeSession(sessionList[index].id ?? "");
                              },
                              child: Container(
                                color: Colors.transparent,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 8.h,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            sessionList[index].title ?? "",
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
                              onTap: () {
                                controller.newSession();
                              },
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
      ),
    );
  }
}
