import 'package:flutter_test/flutter_test.dart';
import 'package:hinata_ai/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils Tests', () {
    test('Formats dateKey as yyyy-MM-dd correctly', () {
      final date = DateTime(2026, 8, 21, 19, 30);
      final key = AppDateUtils.toDateKey(date);
      expect(key, '2026-08-21');
    });

    test('Identifies TODAY relative date header', () {
      final now = DateTime.now();
      final header = AppDateUtils.getRelativeDateHeader(now);
      expect(header, 'TODAY');
    });

    test('Identifies YESTERDAY relative date header', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final header = AppDateUtils.getRelativeDateHeader(yesterday);
      expect(header, 'YESTERDAY');
    });

    test('Identifies PREVIOUS 7 DAYS relative date header', () {
      final fourDaysAgo = DateTime.now().subtract(const Duration(days: 4));
      final header = AppDateUtils.getRelativeDateHeader(fourDaysAgo);
      expect(header, 'PREVIOUS 7 DAYS');
    });
  });
}
