class CoinOrderModel {
  final bool? success;
  final String? message;
  final CoinOrderData? data;

  CoinOrderModel({
    this.success,
    this.message,
    this.data,
  });

  factory CoinOrderModel.fromJson(Map<String, dynamic> json) {
    return CoinOrderModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? CoinOrderData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class CoinOrderData {
  final CoinOrder? order;
  final String? razorpayKeyId;

  CoinOrderData({
    this.order,
    this.razorpayKeyId,
  });

  factory CoinOrderData.fromJson(Map<String, dynamic> json) {
    return CoinOrderData(
      order: json['order'] != null
          ? CoinOrder.fromJson(json['order'] as Map<String, dynamic>)
          : null,
      razorpayKeyId: json['razorpayKeyId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'order': order?.toJson(),
      'razorpayKeyId': razorpayKeyId,
    };
  }
}

class CoinOrder {
  final String? id;
  final String? userId;
  final double? coinsCU;
  final int? amountPaise;
  final String? razorpayOrderId;
  final String? razorpayPaymentId;
  final String? razorpaySignature;
  final String? razorpayMethod;
  final String? status;
  final dynamic metadata;
  final String? createdAt;
  final String? updatedAt;

  CoinOrder({
    this.id,
    this.userId,
    this.coinsCU,
    this.amountPaise,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.razorpaySignature,
    this.razorpayMethod,
    this.status,
    this.metadata,
    this.createdAt,
    this.updatedAt,
  });

  factory CoinOrder.fromJson(Map<String, dynamic> json) {
    return CoinOrder(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      coinsCU: (json['coinsCU'] as num?)?.toDouble(),
      amountPaise: json['amountPaise'] as int?,
      razorpayOrderId: json['razorpayOrderId'] as String?,
      razorpayPaymentId: json['razorpayPaymentId'] as String?,
      razorpaySignature: json['razorpaySignature'] as String?,
      razorpayMethod: json['razorpayMethod'] as String?,
      status: json['status'] as String?,
      metadata: json['metadata'],
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'coinsCU': coinsCU,
      'amountPaise': amountPaise,
      'razorpayOrderId': razorpayOrderId,
      'razorpayPaymentId': razorpayPaymentId,
      'razorpaySignature': razorpaySignature,
      'razorpayMethod': razorpayMethod,
      'status': status,
      'metadata': metadata,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
