import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/app_button.dart';
import 'package:vousvous/core/widgets/common_container.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/wallet/controller/wallet_controller.dart';
import 'package:vousvous/features/wallet/models/wallet_history_model.dart';
import 'package:vousvous/features/wallet/sub-feature/earn_credit/screens/earn_credit_screen.dart';
import 'package:vousvous/features/wallet/sub-feature/what_are_app_credits/screens/what_are_app_credits_screen.dart';
import 'package:vousvous/routes/app_pages.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletController controller = Get.put(WalletController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // Don't trigger loadMore if history is currently loading (e.g., during refresh)
    if (controller.isHistoryLoading.value) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
        isBottomEffect: false,
        isBottomSafeArea: false,
        body: Padding(
          padding: EdgeInsets.only(top: Platform.isAndroid ? 6 : 0),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        wSizedBox16,
                        Text('My Wallet',
                            textAlign: TextAlign.center,
                            style: style700S28.copyWith(
                                color: AppColors.textColor)),
                      ],
                    ),
                    wSizedBox10,
                    IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: SvgPicture.asset(AssetConstants.closeIcon),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () => controller.refreshAll(),
                  color: AppColors.primaryColor,
                  backgroundColor: AppColors.greyBackgroundColor,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Balance Card
                              CommonContainer(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 16),
                                borderRadius: 16,
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                borderGradientColors: AppColors.colorGradient,
                                gradientColors: [
                                  Color(0xFF68C3E7).withAlpha(30),
                                  Color(0xFFFFB86B).withAlpha(30),
                                ],
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Available Balance",
                                      textAlign: TextAlign.start,
                                      style: style400S16.copyWith(
                                          letterSpacing: 0.32,
                                          color: Color(0xFFCCCCCC)),
                                    ),
                                    Obx(() => controller.isLoading.value
                                        ? _buildBalanceShimmer()
                                        : Row(
                                            children: [
                                              Text(
                                                "${controller.formattedBalance} ",
                                                style: style400S24.copyWith(
                                                  letterSpacing: 0.48,
                                                ),
                                              ),
                                              Image.asset(
                                                AssetConstants.vousvousCoin,
                                                height: 24,
                                                width: 24,
                                              ),
                                            ],
                                          )),
                                    Obx(() => controller.isLoading.value
                                        ? _buildRupeeShimmer()
                                        : Text(
                                            "= ${AssetConstants.rupeeSymbol}${controller.rupeeValue}",
                                            textAlign: TextAlign.start,
                                            style: style400S12.copyWith(
                                                letterSpacing: 0.24,
                                                color: Color(0xFFCCCCCC)),
                                          )),
                                    hSizedBox16,
                                    Row(
                                      children: [
                                        Expanded(
                                            child: AppButton(
                                          onTap: () {
                                            Get.toNamed(Routes.buyCredit);
                                          },
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                AssetConstants.vousvousCoinSet,
                                                height: 24,
                                                width: 24,
                                              ),
                                              wSizedBox4,
                                              Flexible(
                                                child: Text(
                                                  "Buy",
                                                  style: style700S16.copyWith(
                                                      color: AppColors
                                                          .greyBackgroundColor),
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                        wSizedBox10,
                                        Expanded(
                                            child: AppButton(
                                          onTap: () {
                                            Get.to(EarnCreditScreen());
                                          },
                                          isGradientBorder: true,
                                          isOutlined: true,
                                          gradientBorderColors:
                                              AppColors.colorGradient,
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Image.asset(
                                                AssetConstants.vousvousCoinSet,
                                                height: 24,
                                                width: 24,
                                              ),
                                              wSizedBox4,
                                              Flexible(
                                                child: Text(
                                                  "Earn",
                                                  style: style700S16.copyWith(),
                                                ),
                                              )
                                            ],
                                          ),
                                        )),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              hSizedBox12,
                              GestureDetector(
                                onTap: () {
                                  Get.to(WhatAreAppCreditsScreen());
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    SvgPicture.asset(AssetConstants.infoCircle),
                                    wSizedBox4,
                                    Flexible(
                                      child: Text(
                                        "What are App Credits?",
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        style: style400S14.copyWith(
                                            letterSpacing: 0.28,
                                            color: const Color(0xFFFFB86B)),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              hSizedBox30,
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      "Credit History",
                                      overflow: TextOverflow.ellipsis,
                                      style: style700S16.copyWith(
                                        letterSpacing: 0.32,
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(Routes.creditHistory);
                                    },
                                    child: Row(
                                      children: [
                                        Text(
                                          "See all",
                                          overflow: TextOverflow.ellipsis,
                                          style: style400S14.copyWith(),
                                        ),
                                        wSizedBox4,
                                        Transform.rotate(
                                            angle: 3.14159,
                                            child: SvgPicture.asset(
                                              AssetConstants.backward,
                                              height: 18,
                                            )),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      // History List
                      Obx(() {
                        if (controller.isHistoryLoading.value) {
                          return SliverToBoxAdapter(
                            child: _buildHistoryShimmer(),
                          );
                        }

                        if (controller.historyItems.isEmpty) {
                          return SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                "No transactions yet",
                                style: style400S14.copyWith(
                                    color: Color(0xFF999999)),
                              ),
                            ),
                          );
                        }

                        // Group items by date
                        final groupedItems =
                            _groupHistoryByDate(controller.historyItems);
                        final dateKeys = groupedItems.keys.toList();

                        return SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                // Calculate which date group and item we're at
                                int itemCount = 0;
                                for (int i = 0; i < dateKeys.length; i++) {
                                  final dateKey = dateKeys[i];
                                  final items = groupedItems[dateKey]!;

                                  // Check if this index is the header
                                  if (index == itemCount) {
                                    return _buildDateHeader(dateKey);
                                  }
                                  itemCount++;

                                  // Check if this index is within the items of this group
                                  if (index < itemCount + items.length) {
                                    final itemIndex = index - itemCount;
                                    final item = items[itemIndex];
                                    final isLastInGroup =
                                        itemIndex == items.length - 1;
                                    return _buildHistoryTile(item,
                                        showDivider: !isLastInGroup);
                                  }
                                  itemCount += items.length;
                                }

                                // Loading more indicator
                                return Obx(() {
                                  if (controller.isLoadingMore.value) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      child: Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primaryColor,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox(height: 16);
                                });
                              },
                              childCount:
                                  _calculateTotalItemCount(groupedItems) + 1,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  /// Group history items by date (Today, Yesterday, or specific date)
  Map<String, List<WalletHistoryItem>> _groupHistoryByDate(
      List<WalletHistoryItem> items) {
    final Map<String, List<WalletHistoryItem>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      String dateKey;
      if (item.createdAt != null) {
        try {
          final date = DateTime.parse(item.createdAt!).toLocal();
          final itemDate = DateTime(date.year, date.month, date.day);

          if (itemDate == today) {
            dateKey = 'TODAY';
          } else if (itemDate == yesterday) {
            dateKey = 'YESTERDAY';
          } else {
            dateKey = DateFormat('dd MMM yyyy').format(date).toUpperCase();
          }
        } catch (e) {
          dateKey = 'UNKNOWN';
        }
      } else {
        dateKey = 'UNKNOWN';
      }

      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(item);
    }

    return grouped;
  }

  /// Calculate total items including headers
  int _calculateTotalItemCount(Map<String, List<WalletHistoryItem>> grouped) {
    int count = 0;
    for (final key in grouped.keys) {
      count += 1; // Header
      count += grouped[key]!.length; // Items
    }
    return count;
  }

  /// Build date section header
  Widget _buildDateHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4),
      child: Text(
        title,
        style: style700S14.copyWith(
          color: Color(0xFF999999),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHistoryTile(WalletHistoryItem item, {bool showDivider = true}) {
    final formattedTime = _formatTime(item.createdAt);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title ?? "-",
                      overflow: TextOverflow.ellipsis,
                      style: style400S18.copyWith(
                        color: Colors.white,
                        letterSpacing: 0.36,
                      ),
                    ),
                    hSizedBox4,
                    Text(
                      formattedTime,
                      overflow: TextOverflow.ellipsis,
                      style: style400S14.copyWith(
                        color: Color(0xFF999999),
                        letterSpacing: 0.28,
                      ),
                    ),
                  ],
                ),
              ),
              wSizedBox16,
              Text(
                item.formattedAmount,
                style: style400S20.copyWith(
                  color: item.isCredit ? Color(0xFF4ADE80) : Color(0xFFEF4444),
                  letterSpacing: 0.44,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Container(
            height: 0.5,
            color: Color(0xFF333333),
          ),
      ],
    );
  }

  /// Format time for display (e.g., "Today 10:41 AM", "Yesterday 10:41 AM")
  String _formatTime(String? dateString) {
    if (dateString == null) return '';
    try {
      final date = DateTime.parse(dateString).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final itemDate = DateTime(date.year, date.month, date.day);

      final timeStr = DateFormat('h:mm a').format(date);

      if (itemDate == today) {
        return 'Today $timeStr';
      } else if (itemDate == yesterday) {
        return 'Yesterday $timeStr';
      } else {
        return '${DateFormat('dd MMM').format(date)} $timeStr';
      }
    } catch (e) {
      return dateString;
    }
  }

  Widget _buildBalanceShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Container(
        height: 28,
        width: 140,
        margin: EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _buildRupeeShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Container(
        height: 14,
        width: 70,
        margin: EdgeInsets.only(top: 4),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildHistoryShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          10,
          (index) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[900]!,
              highlightColor: Colors.black,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
