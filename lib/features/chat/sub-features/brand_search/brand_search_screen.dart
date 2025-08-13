import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/sizedbox.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/app_text_field.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:ai_fashion/core/widgets/custom_scaffold.dart';
import 'package:ai_fashion/features/chat/controller/chat_controller.dart';
import 'package:ai_fashion/features/chat/sub-features/brand_search/controller/brand_search_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class BrandSearchScreen extends StatefulWidget {
  const BrandSearchScreen({super.key});

  @override
  State<BrandSearchScreen> createState() => _BrandSearchScreenState();
}

class _BrandSearchScreenState extends State<BrandSearchScreen> {
  final controller = Get.put(BrandSearchController());
  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isBottomEffect: false,
      body: Container(
        decoration: BoxDecoration(
            color: AppColors.blackColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        padding: EdgeInsets.only(top: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Get.back();
                    },
                    icon: SvgPicture.asset(AssetConstants.backward),
                  ),
                  Expanded(
                    child: AppTextField(
                      autofocus: true,
                      borderColor: Colors.transparent,
                      fillColor: AppColors.grey2Color,
                      hint: 'Search Brands',
                      outsideMargin:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      contentPadding: EdgeInsets.zero,
                      borderRadius: 100,
                      hintStyle: style400S14.copyWith(
                        letterSpacing: 0.28,
                        color: Color(0xFF999999),
                      ),
                      prefixIcon: SvgPicture.asset(
                        AssetConstants.search,
                      ),
                    ),
                  ),
                  wSizedBox16,
                ],
              ),
            ),
            hSizedBox10,
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: 20,
                itemBuilder: (context, index) {
                  return CommonContainer(
                      onTap: () {
                        Get.back();
                        Get.find<ChatController>()
                            .sendMessage(message: "Dresses by Zara");
                        Get.find<ChatController>().showBrandContainer.value =
                            false;
                      },
                      backgroundColor: AppColors.grey2Color,
                      borderRadius: 10,
                      child: AppNetworkImage(
                        imageUrl:
                            "https://i.pinimg.com/474x/af/84/6e/af846e8b9c2f4ecec25e6a13e0faa07e.jpg",
                        fit: BoxFit.cover,
                      ));
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
