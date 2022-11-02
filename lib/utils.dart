import 'package:flutter/material.dart';

/// simple string datetime for storage
/// uses today's date to compose a valid date, but we don't care about the date
String datetimeStrFromTimeOfDay(TimeOfDay time) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, time.hour, time.minute).toString();
}

/// parse datetime string back to a TimeOfDay (without date!)
TimeOfDay datetimeStrToTimeOfDay(String time) => TimeOfDay.fromDateTime(DateTime.parse(time));

/// returns TimeOfDay formatted to text based on user preference (12 or 24h)
String displayTextFromToD(BuildContext context, TimeOfDay time) => time.format(context);

List<String> parseFromTimeOfDay(List<TimeOfDay> wakes) =>
    wakes.map((w) => datetimeStrFromTimeOfDay(w)).toList();

List<TimeOfDay> parseToTimeOfDay(List<String> wakes) =>
    wakes.map((w) => datetimeStrToTimeOfDay(w)).toList();

TimeOfDay calcTempMin(List<TimeOfDay> values) {
  final sum = values.fold(0.0, (previousValue, value) {
    final current = value.hour + (value.minute / 60);
    return previousValue + current;
  });

  double average = sum / values.length;
  int hours = average.truncate();
  double minutes = average - hours;

  TimeOfDay averageWakeupTime = TimeOfDay(hour: hours, minute: (minutes * 60).round());
  TimeOfDay tempMinTime =
      TimeOfDay(hour: averageWakeupTime.hour - 2, minute: averageWakeupTime.minute);

  return tempMinTime;
}

List<T> finiteAddToList<T>(List<T> list, T value, [int limit = 5]) {
  if (list.length >= limit) {
    return [...list.sublist(0, 4), value];
  }

  return [...list, value];
}
