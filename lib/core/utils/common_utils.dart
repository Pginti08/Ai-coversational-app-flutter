import 'package:intl/intl.dart';

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
