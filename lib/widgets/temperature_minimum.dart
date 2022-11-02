import 'package:flutter/material.dart';

import '../utils.dart';

class TemperatureMinimum extends StatelessWidget {
  final List<TimeOfDay> wakes;
  const TemperatureMinimum(this.wakes, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      displayTextFromToD(context, calcTempMin(wakes)),
      style: Theme.of(context).textTheme.headline2?.copyWith(color: Colors.black87),
      textAlign: TextAlign.center,
    );
  }
}
