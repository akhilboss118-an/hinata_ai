import 'package:intl/intl.dart';

/// Date utility functions for dateKey generation & conversation grouping
abstract class AppDateUtils {
  static final DateFormat _keyFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('MMMM d, yyyy');
  static final DateFormat _timeFormat = DateFormat('h:mm a');

  /// Returns machine-readable date key (e.g. 2026-08-21)
  static String toDateKey(DateTime dateTime) {
    return _keyFormat.format(dateTime.toLocal());
  }

  /// Formats date for UI display
  static String formatDisplay(DateTime dateTime) {
    return _displayFormat.format(dateTime.toLocal());
  }

  /// Formats time for message bubbles (e.g. 7:30 PM)
  static String formatTime(DateTime dateTime) {
    return _timeFormat.format(dateTime.toLocal());
  }

  /// Returns human relative category ("TODAY", "YESTERDAY", "PREVIOUS 7 DAYS", etc.)
  static String getRelativeDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final itemDate = DateTime(date.year, date.month, date.day);
    final difference = today.difference(itemDate).inDays;

    if (difference == 0) return 'TODAY';
    if (difference == 1) return 'YESTERDAY';
    if (difference <= 7) return 'PREVIOUS 7 DAYS';
    if (difference <= 30) return 'PREVIOUS 30 DAYS';
    return DateFormat('MMMM yyyy').format(date).toUpperCase();
  }
}
