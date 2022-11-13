import 'package:flutter/material.dart';

typedef Wakes = List<TimeOfDay>;

class Globals {
  static const appTitle = 'Temperature Minimum';

  // ui
  static const padding = 8.0;

  // flags
  static const isDev = false;

  // prefs
  static const wakesStorageKey = 'wakes';
}
