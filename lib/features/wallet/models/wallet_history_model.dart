// To parse this JSON data, do
//
//     final walletHistoryModel = walletHistoryModelFromJson(jsonString);

import 'dart:convert';

WalletHistoryModel walletHistoryModelFromJson(String str) =>
    WalletHistoryModel.fromJson(json.decode(str));

String walletHistoryModelToJson(WalletHistoryModel data) =>
    json.encode(data.toJson());

class WalletHistoryModel {
  final bool? success;
  final String? message;
  final Data? data;

  WalletHistoryModel({
    this.success,
    this.message,
    this.data,
  });

  factory WalletHistoryModel.fromJson(Map<String, dynamic> json) =>
      WalletHistoryModel(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };
}

class Data {
  final List<WalletHistory>? items;
  final int? total;
  final int? page;
  final int? limit;

  Data({
    this.items,
    this.total,
    this.page,
    this.limit,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        items: json["items"] == null
            ? []
            : List<WalletHistory>.from(
                json["items"]!.map((x) => WalletHistory.fromJson(x))),
        total: json["total"],
        page: json["page"],
        limit: json["limit"],
      );

  Map<String, dynamic> toJson() => {
        "items": items == null
            ? []
            : List<dynamic>.from(items!.map((x) => x.toJson())),
        "total": total,
        "page": page,
        "limit": limit,
      };
}

class WalletHistory {
  final String? id;
  final String? userId;
  final double? amountCu;
  final String? source;
  final String? referenceId;
  final String? referenceType;
  final String? provider;
  final String? providerRef;
  final String? razorpayMethod;
  final String? description;
  final String? title;
  final String? status;
  final double? balanceBefore;
  final double? balanceAfter;
  final String? direction;
  final dynamic metadata;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  WalletHistory({
    this.id,
    this.userId,
    this.amountCu,
    this.source,
    this.referenceId,
    this.referenceType,
    this.provider,
    this.providerRef,
    this.razorpayMethod,
    this.description,
    this.title,
    this.status,
    this.balanceBefore,
    this.balanceAfter,
    this.direction,
    this.metadata,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory WalletHistory.fromJson(Map<String, dynamic> json) => WalletHistory(
        id: json["_id"],
        userId: json["userId"],
        amountCu: json["amountCU"]?.toDouble(),
        source: json["source"],
        referenceId: json["referenceId"],
        referenceType: json["referenceType"],
        provider: json["provider"],
        providerRef: json["providerRef"],
        razorpayMethod: json["razorpayMethod"],
        description: json["description"],
        title: json["title"],
        status: json["status"],
        balanceBefore: json["balanceBefore"]?.toDouble(),
        balanceAfter: json["balanceAfter"]?.toDouble(),
        direction: json["direction"],
        metadata: json["metadata"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "amountCU": amountCu,
        "source": source,
        "referenceId": referenceId,
        "referenceType": referenceType,
        "provider": provider,
        "providerRef": providerRef,
        "razorpayMethod": razorpayMethod,
        "description": description,
        "title": title,
        "status": status,
        "balanceBefore": balanceBefore,
        "balanceAfter": balanceAfter,
        "direction": direction,
        "metadata": metadata,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };

  /// Check if this is a credit (positive) transaction
  bool get isCredit => direction == "CREDIT";

  /// Get formatted amount with sign
  String get formattedAmount {
    if (amountCu == null) return '0';
    final sign = isCredit ? '+' : '';
    // Format: remove trailing .0 if integer
    String amountStr = amountCu.toString();
    if (amountStr.endsWith('.0')) {
      amountStr = amountStr.substring(0, amountStr.length - 2);
    }
    return '$sign$amountStr';
  }
}

class MetadataClass {
  final String? razorpayOrderId;
  final String? event;
  final int? amountPaise;
  final int? amountInr;
  final double? coinsCu;
  final String? quotationCardId;
  final int? totalAmount;
  final double? coinsRequired;

  MetadataClass({
    this.razorpayOrderId,
    this.event,
    this.amountPaise,
    this.amountInr,
    this.coinsCu,
    this.quotationCardId,
    this.totalAmount,
    this.coinsRequired,
  });

  factory MetadataClass.fromJson(Map<String, dynamic> json) => MetadataClass(
        razorpayOrderId: json["razorpayOrderId"],
        event: json["event"],
        amountPaise: json["amountPaise"],
        amountInr: json["amountINR"],
        coinsCu: json["coinsCU"]?.toDouble(),
        quotationCardId: json["quotationCardId"],
        totalAmount: json["totalAmount"],
        coinsRequired: json["coinsRequired"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "razorpayOrderId": razorpayOrderId,
        "event": event,
        "amountPaise": amountPaise,
        "amountINR": amountInr,
        "coinsCU": coinsCu,
        "quotationCardId": quotationCardId,
        "totalAmount": totalAmount,
        "coinsRequired": coinsRequired,
      };
}
