import 'package:ai_fashion/core/constants/asset_constants.dart';
import 'package:ai_fashion/core/theme/app_colors.dart';
import 'package:ai_fashion/core/theme/app_styles.dart';
import 'package:ai_fashion/core/utils/common_utils.dart';
import 'package:ai_fashion/core/widgets/app_network_image.dart';
import 'package:ai_fashion/core/widgets/common_container.dart';
import 'package:ai_fashion/features/home/models/product_list_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ProductOutfitCard extends StatefulWidget {
  const ProductOutfitCard({
    super.key,
    required this.product,
    required this.isFirst,
    this.swipeProgress = 0,
    this.onTap,
  });

  final Product product;
  final RxBool isFirst;
  final double swipeProgress;
  final void Function()? onTap;

  @override
  State<ProductOutfitCard> createState() => _ProductOutfitCardState();
}

class _ProductOutfitCardState extends State<ProductOutfitCard> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withAlpha(100),
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: AppNetworkImage(
              imageUrl: widget.product.image ?? "",
              fit: BoxFit.cover,
              onTap: widget.onTap,
            ),
          ),
        ),

        Positioned.fill(
            child: IgnorePointer(
          child: Container(
              decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: widget.swipeProgress > 0
                ? Colors.pink.withAlpha(30)
                : widget.swipeProgress < 0
                    ? Colors.white.withAlpha(30)
                    : null,
          )),
        )),
        // ❤️ Heart icon on top-left
        if (widget.swipeProgress > 0)
          Positioned(
            top: 12,
            left: 12,
            child: IgnorePointer(
              child: SvgPicture.asset(
                AssetConstants.heart,
                height: 80,
                color: Colors.pink.withAlpha(100),
              ),
            ),
          ),

        if (widget.swipeProgress < 0)
          Positioned(
            top: 12,
            right: 12,
            child: IgnorePointer(
              child: SvgPicture.asset(
                AssetConstants.previous,
                height: 80,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),

        // 🏷️ Title on bottom blur
        if (widget.isFirst.value && isNotNullOrEmpty(widget.product.title))
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: CommonContainer(
                blurStrength: 30,
                enableBlur: true,
                borderRadius: 100,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                borderColor: AppColors.whiteColor.withAlpha(20),
                backgroundColor: AppColors.blackColor.withAlpha(70),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.product.title ?? "",
                        overflow: TextOverflow.ellipsis,
                        style: style500S16.copyWith(letterSpacing: 0.32),
                      ),
                    ),
                    // wSizedBox10,
                    // horizontalStackedAvatars(widget.outfit.colors ?? []),
                  ],
                ),
              ),
            ),
          )
      ],
    );
  }

  // Widget horizontalStackedAvatars(List<Color> colors) {
  //   final double size = 28;
  //   final double overlap = 15;
  //   final int displayCount = colors.length > 3 ? 3 : colors.length;
  //   final double totalWidth = size + (displayCount - 1) * (size - overlap);

  //   return SizedBox(
  //     height: size,
  //     width: totalWidth,
  //     child: Stack(
  //       children: List.generate(displayCount, (index) {
  //         final reversedIndex = displayCount - 1 - index;
  //         return Positioned(
  //           left: reversedIndex * (size - overlap),
  //           child: Container(
  //             height: size,
  //             width: size,
  //             decoration: BoxDecoration(
  //               shape: BoxShape.circle,
  //               color: colors[reversedIndex],
  //             ),
  //           ),
  //         );
  //       }),
  //     ),
  //   );
  // }
}
