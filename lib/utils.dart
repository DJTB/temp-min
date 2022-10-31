import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import "globals.dart";

TimeOfDay strToToD(String time, [is24Hr = false]) {
  final format = is24Hr ? DateFormat.Hms() : DateFormat.jm();
  return TimeOfDay.fromDateTime(format.parse(time));
}

String strFromToD(BuildContext context, TimeOfDay time) {
  return time.format(context);
}

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

  if (Globals.isDev) {
    print('fractional sum $sum');
    print('fractional average $average');
    print('averageWakeupTime $averageWakeupTime');
  }

  return tempMinTime;
}

List<T> finiteAddToList<T>(List<T> list, T value, [int limit = 5]) {
  if (list.length >= limit) {
    return [...list.sublist(0, 4), value];
  }

  return [...list, value];
}
