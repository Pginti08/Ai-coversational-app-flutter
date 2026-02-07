import 'package:intl/intl.dart';

extension StringExtension on String {
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }
}

extension DateTimeExtension on DateTime {
  String toFormattedDate() {
    return DateFormat('MMM dd, yyyy').format(this);
  }

  String toFormattedDateTime() {
    return DateFormat('MMM dd, yyyy HH:mm').format(this);
  }
}

extension NumericExtension on num {
  String toCurrency() {
    return NumberFormat.currency(symbol: r'$').format(this);
  }

  String toFormattedPrice() {
    return NumberFormat("#,##0.##").format(this);
  }

  String toFormattedCoins() {
    return NumberFormat("0.##").format(this);
  }
}
