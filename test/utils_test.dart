import 'package:flutter/material.dart';

import 'package:temp_min/utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsers', () {
    test('datetimeStrFromTimeOfDay', () {
      var now = DateTime.now();
      var expected = DateTime(now.year, now.month, now.day, 6, 30).toString();
      var result = datetimeStrFromTimeOfDay(const TimeOfDay(hour: 6, minute: 30));
      expect(result, expected);
    });
    test('datetimeStrToTimeOfDay', () {
      const expected = TimeOfDay(hour: 6, minute: 30);
      var result = datetimeStrToTimeOfDay(DateTime.utc(2022, 1, 1, 6, 30).toString());
      expect(result, expected);
    });
  });

  group('finiteAddToList', () {
    test('should work with an empty list', () {
      var expected = [1];
      var result = finiteAddToList([], 1);
      expect(result, expected);
    });
    test('should work with existing values', () {
      var expected = [1, 2, 3];
      var result = finiteAddToList([1, 2], 3);
      expect(result, expected);
    });
    test('should have a default max limit', () {
      var expected = [1, 2, 3, 4, 6];
      var result = finiteAddToList([1, 2, 3, 4, 5], 6);
      expect(result, expected);
    });
    test('should replace final value if list is equal to limit', () {
      var expected = [1, 2, 3, 4, 5, 7];
      var result = finiteAddToList([1, 2, 3, 4, 5, 6], 7, limit: 6);
      expect(result, expected);
    });
    test('should remove initial value and replace final value if list is greater than limit', () {
      var expected = [2, 3, 4, 5, 6, 8];
      var result = finiteAddToList([1, 2, 3, 4, 5, 6, 7], 8, limit: 6);
      expect(result, expected);
    });
  });

  group('calcTempMin', () {
    test('should work with an empty list', () {
      const expected = TimeOfDay(hour: 24, minute: 00);
      var result = calcTempMin([]);

      expect(result, expected);
    });
    test('should work with a single value', () {
      const expected = TimeOfDay(hour: 4, minute: 30);
      var result = calcTempMin([const TimeOfDay(hour: 6, minute: 30)]);

      expect(result, expected);
    });
    test('should sum multiple values (2)', () {
      const expected = TimeOfDay(hour: 4, minute: 00);
      var result = calcTempMin([
        const TimeOfDay(hour: 6, minute: 30),
        const TimeOfDay(hour: 5, minute: 30),
      ]);

      expect(result, expected);
    });
    test('should sum multiple values (5)', () {
      const expected = TimeOfDay(hour: 4, minute: 00);

      var result = calcTempMin([
        const TimeOfDay(hour: 5, minute: 00),
        const TimeOfDay(hour: 5, minute: 30),
        const TimeOfDay(hour: 6, minute: 00),
        const TimeOfDay(hour: 6, minute: 30),
        const TimeOfDay(hour: 7, minute: 00),
      ]);

      expect(result, expected);
    });
  });
}
