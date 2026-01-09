import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:vousvous/core/constants/api_constants.dart';
import 'package:vousvous/core/constants/asset_constants.dart';

bool isNullOrEmpty(dynamic val) {
  final value = val.toString();
  return val == null ||
      value.isEmpty ||
      value == 'null' ||
      value == '' ||
      value == 'NULL' ||
      value == '{}' ||
      value == '[]';
}

bool isNotNullOrEmpty(dynamic val) {
  final value = val.toString();
  return !(val == null ||
      value.isEmpty ||
      value == 'null' ||
      value == '' ||
      value == 'NULL' ||
      value == '{}' ||
      value == '[]');
}

bool isUrl(String? input) {
  // Regular expression pattern to match URLs
  final urlRegExp = RegExp(r'^(?:http|https):\/\/[^\s]+');

  return isNullOrEmpty(input) ? false : urlRegExp.hasMatch(input!);
}

String formatTime(int totalSeconds) {
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;
  final seconds = totalSeconds % 60;

  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${seconds.toString().padLeft(2, '0')}';
}

String formatNumber(double number) {
  // Convert the number to a string with two decimal places
  String formatted = number.toStringAsFixed(2);

  // Check if the formatted number ends with ".00" or ".0"
  if (formatted.endsWith(".00")) {
    // Remove the ".00"
    return formatted.split(".")[0];
  } else if (formatted.endsWith(".0")) {
    // Remove the ".0"
    return formatted.split(".")[0];
  }

  return formatted;
}

String removeEmojis(String input) {
  return input.replaceAll(RegExp(r'[^\w\s]'), '').trim();
}

String maskEmail(String email) {
  if (!email.contains('@')) return email;

  final parts = email.split('@');
  final name = parts[0];
  final domain = parts[1];

  if (name.length <= 1) {
    return '${name[0]}*****@$domain';
  }

  final masked = name[0] + '*' * (name.length - 2) + name[name.length - 1];
  return '$masked@$domain';
}

String indianRupeeAmountConversion(double? amount, {int? decimalDigits}) {
  try {
    String formattedAmount = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹',
      decimalDigits: decimalDigits ?? 2,
    ).format(amount ?? 0.0);
    return formattedAmount;
  } catch (e) {
    return "Invalid";
  }
}

bool isJson(String? str) {
  if (str == null || str.isEmpty) return false;
  try {
    json.decode(str);
    return true;
  } catch (e) {
    return false;
  }
}

String jsonToReadableText(String jsonString, {int indent = 0}) {
  try {
    final dynamic data = json.decode(jsonString);
    return _convertJsonToText(data, indent);
  } catch (e) {
    return "⚠️ Invalid JSON format";
  }
}

String bulkQuantitiesToReadableText(dynamic bulkQuantities) {
  try {
    if (bulkQuantities == null || bulkQuantities.isEmpty) return "-";

    final sizes = bulkQuantities['sizes'];
    if (sizes == null || sizes is! Map || sizes.isEmpty) return "-";

    return sizes.entries.map((e) => "${e.key}: ${e.value}").join(", ");
  } catch (e) {
    return "-";
  }
}

String _convertJsonToText(dynamic data, int indent) {
  final buffer = StringBuffer();
  final space = '  ' * indent;

  if (data is Map<String, dynamic>) {
    data.forEach((key, value) {
      if (value is Map || value is List) {
        buffer.writeln("$space${_capitalize(key)}:");
        buffer.write(_convertJsonToText(value, indent + 1));
      } else {
        buffer.writeln("$space${_capitalize(key)}: $value");
      }
    });
  } else if (data is List) {
    for (int i = 0; i < data.length; i++) {
      buffer.writeln("${space}• Item ${i + 1}:");
      buffer.write(_convertJsonToText(data[i], indent + 1));
    }
  } else {
    buffer.writeln("$space$data");
  }

  // ✅ remove trailing newline before returning
  return buffer.toString().trimRight();
}

String _capitalize(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

String fullImageUrl(String imageUrl) {
  if (imageUrl.isEmpty) return '';

  // Check if URL already has a protocol
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl;
  }

  // Otherwise, prepend the base URL
  return '${ApiConstants.imageURL}$imageUrl';
}

String getOrderStatusIcon(String orderStatus) {
  switch (orderStatus) {
    case 'PENDING_PAYMENT':
      return AssetConstants.emptyWalletTime;

    case 'ORDER_PLACED':
      return AssetConstants.box;

    case 'PROCESSING':
      return AssetConstants.scissor;

    case 'SHIPPED':
      return AssetConstants.truckTime;
    case 'OUT_FOR_DELIVERY':
      return AssetConstants.truckTick;

    case 'DELIVERED':
      return AssetConstants.boxTick;

    default:
      return AssetConstants.box;
  }
}

String formatTimeAgo(DateTime? dateTime) {
  if (dateTime == null) return "Unknown";

  final now = DateTime.now();
  final difference = now.difference(dateTime);

  if (difference.inMinutes < 1) {
    return "Just now";
  } else if (difference.inMinutes < 60) {
    return "${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago";
  } else if (difference.inHours < 24) {
    return "${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago";
  } else if (difference.inDays < 77) {
    return "${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago";
  } else {
    return DateFormat('dd MMMM yyyy').format(dateTime);
  }
}
