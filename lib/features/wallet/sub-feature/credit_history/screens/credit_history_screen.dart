import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vousvous/core/constants/asset_constants.dart';
import 'package:vousvous/core/theme/app_colors.dart';
import 'package:vousvous/core/theme/app_styles.dart';
import 'package:vousvous/core/utils/sizedbox.dart';
import 'package:vousvous/core/widgets/custom_scaffold.dart';
import 'package:vousvous/features/wallet/models/wallet_history_model.dart';
import 'package:vousvous/features/wallet/sub-feature/credit_history/controller/credit_history_controller.dart';

class CreditHistoryScreen extends StatefulWidget {
  const CreditHistoryScreen({super.key});

  @override
  State<CreditHistoryScreen> createState() => _CreditHistoryScreenState();
}

class _CreditHistoryScreenState extends State<CreditHistoryScreen> {
  final CreditHistoryController controller = Get.put(CreditHistoryController());

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      isBottomEffect: false,
      isBottomSafeArea: false,
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6).copyWith(bottom: 0),
        child: Column(
          children: [
            // Header
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Credit History'.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: style700S14.copyWith(
                            color: Color(0xFFCCCCCC), letterSpacing: 0.96)),
                  ],
                ),
                Positioned(
                  left: 0,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: SvgPicture.asset(
                      AssetConstants.backward,
                      height: 24,
                    ),
                  ),
                ),
              ],
            ),
            hSizedBox24,
            // List
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return _buildShimmerList();
                }

                return RefreshIndicator(
                  onRefresh: () => controller.fetchHistory(isInitial: true),
                  color: AppColors.primaryColor,
                  backgroundColor: AppColors.greyBackgroundColor,
                  child: controller.historyItems.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 200),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    AssetConstants.wallet,
                                    width: 60,
                                    color: Color(0xFF666666),
                                  ),
                                  hSizedBox16,
                                  Text(
                                    "No transactions yet",
                                    style: style400S16.copyWith(
                                        color: Color(0xFF999999)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : _buildGroupedList(),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupedList() {
    final groupedItems = _groupHistoryByDate(controller.historyItems);
    final dateKeys = groupedItems.keys.toList();

    return ListView.builder(
      controller: controller.scrollController,
      physics: const AlwaysScrollableScrollPhysics()
          .applyTo(const BouncingScrollPhysics()),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _calculateTotalItemCount(groupedItems) + 1,
      itemBuilder: (context, index) {
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
            final isLastInGroup = itemIndex == items.length - 1;
            return _buildHistoryTile(item, showDivider: !isLastInGroup);
          }
          itemCount += items.length;
        }

        // Loading more indicator
        return Obx(() {
          if (controller.paginationLoading.value) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }

  /// Group history items by date (Today, Yesterday, or specific date)
  Map<String, List<WalletHistory>> _groupHistoryByDate(
      List<WalletHistory> items) {
    final Map<String, List<WalletHistory>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      String dateKey;
      if (item.createdAt != null) {
        try {
          final date = item.createdAt!.toLocal();
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
  int _calculateTotalItemCount(Map<String, List<WalletHistory>> grouped) {
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

  Widget _buildHistoryTile(WalletHistory item, {bool showDivider = true}) {
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
  String _formatTime(DateTime? date) {
    if (date == null) return '';
    try {
      final localDate = date.toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final itemDate = DateTime(localDate.year, localDate.month, localDate.day);

      final timeStr = DateFormat('h:mm a').format(localDate);

      if (itemDate == today) {
        return 'Today $timeStr';
      } else if (itemDate == yesterday) {
        return 'Yesterday $timeStr';
      } else {
        return '${DateFormat('dd MMM').format(localDate)} $timeStr';
      }
    } catch (e) {
      return '';
    }
  }

  Widget _buildShimmerList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            12,
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
      ),
    );
  }
}
