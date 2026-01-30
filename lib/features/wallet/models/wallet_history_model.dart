class WalletHistoryModel {
  final bool? success;
  final String? message;
  final WalletHistoryData? data;

  WalletHistoryModel({
    this.success,
    this.message,
    this.data,
  });

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) {
    return WalletHistoryModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? WalletHistoryData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }
}

class WalletHistoryData {
  final List<WalletHistoryItem>? items;
  final int? total;
  final int? page;
  final int? limit;

  WalletHistoryData({
    this.items,
    this.total,
    this.page,
    this.limit,
  });

  factory WalletHistoryData.fromJson(Map<String, dynamic> json) {
    return WalletHistoryData(
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) =>
                  WalletHistoryItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      total: json['total'] as int?,
      page: json['page'] as int?,
      limit: json['limit'] as int?,
    );
  }

  int get totalPages => (total != null && limit != null && limit! > 0)
      ? ((total! + limit! - 1) ~/ limit!)
      : 1;

  bool get hasMore => (page ?? 1) < totalPages;
}

class WalletHistoryItem {
  final String? id;
  final String? userId;
  final double? amountCU;
  final String? source;
  final String? referenceId;
  final String? referenceType;
  final String? provider;
  final String? providerRef;
  final String? razorpayMethod;
  final String? description;
  final String? status;
  final double? balanceBefore;
  final double? balanceAfter;
  final String? direction;
  final Map<String, dynamic>? metadata;
  final String? createdAt;
  final String? updatedAt;

  WalletHistoryItem({
    this.id,
    this.userId,
    this.amountCU,
    this.source,
    this.referenceId,
    this.referenceType,
    this.provider,
    this.providerRef,
    this.razorpayMethod,
    this.description,
    this.status,
    this.balanceBefore,
    this.balanceAfter,
    this.direction,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory WalletHistoryItem.fromJson(Map<String, dynamic> json) {
    return WalletHistoryItem(
      id: json['_id'] as String?,
      userId: json['userId'] as String?,
      amountCU: (json['amountCU'] as num?)?.toDouble(),
      source: json['source'] as String?,
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
      provider: json['provider'] as String?,
      providerRef: json['providerRef'] as String?,
      razorpayMethod: json['razorpayMethod'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String?,
      balanceBefore: (json['balanceBefore'] as num?)?.toDouble(),
      balanceAfter: (json['balanceAfter'] as num?)?.toDouble(),
      direction: json['direction'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// Check if this is a credit (positive) transaction
  bool get isCredit => direction == 'CREDIT';

  /// Get formatted amount with sign
  String get formattedAmount {
    if (amountCU == null) return '0';
    final sign = isCredit ? '+' : '-';
    if (amountCU == amountCU!.truncate()) {
      return '$sign${amountCU!.toStringAsFixed(0)}';
    }
    return '$sign${amountCU!.toStringAsFixed(2).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '')}';
  }

  /// Get display title from source
  String get displayTitle {
    if (description != null && description!.isNotEmpty) {
      return description!;
    }
    // Format source to readable text
    switch (source) {
      case 'COIN_PURCHASE':
        return 'Credits purchased';
      case 'AI_DESIGN_GENERATE':
        return 'AI Design Generate';
      case 'TRY_ON_SESSION':
        return 'Try-on session';
      case 'ORDER_CASHBACK':
        return 'Order cashback';
      case 'REFERRAL_BONUS':
        return 'Referral bonus';
      default:
        return source?.replaceAll('_', ' ').toLowerCase().capitalizeFirst ??
            'Transaction';
    }
  }
}

extension StringExtension on String {
  String? get capitalizeFirst {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
