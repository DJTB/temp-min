import 'package:flutter/material.dart';

import 'globals.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Globals.appTitle,
      theme: ThemeData.light(),
      home: const HomeScreen(title: Globals.appTitle),
    );
  }
}
