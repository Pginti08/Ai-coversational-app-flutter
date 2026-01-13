import 'package:intl/intl.dart';

String getDateLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final messageDate = DateTime(date.year, date.month, date.day);

  if (messageDate == today) {
    return 'Today';
  } else if (messageDate == yesterday) {
    return 'Yesterday';
  } else {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}

bool shouldShowDateHeader(DateTime? currentDate, DateTime? previousDate) {
  if (currentDate == null) return false;
  if (previousDate == null) return true;

  final current = DateTime(currentDate.year, currentDate.month, currentDate.day);
  final previous = DateTime(previousDate.year, previousDate.month, previousDate.day);

  return current != previous;
}
