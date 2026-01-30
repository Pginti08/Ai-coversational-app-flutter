class WalletBalanceModel {
  final bool? success;
  final String? message;
  final WalletBalanceData? data;

  WalletBalanceModel({
    this.success,
    this.message,
    this.data,
  });

  factory WalletBalanceModel.fromJson(Map<String, dynamic> json) {
    return WalletBalanceModel(
      success: json['success'] as bool?,
      message: json['message'] as String?,
      data: json['data'] != null
          ? WalletBalanceData.fromJson(json['data'] as Map<String, dynamic>)
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

class WalletBalanceData {
  final double? balanceCU;

  WalletBalanceData({
    this.balanceCU,
  });

  factory WalletBalanceData.fromJson(Map<String, dynamic> json) {
    return WalletBalanceData(
      balanceCU: (json['balanceCU'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balanceCU': balanceCU,
    };
  }
}
