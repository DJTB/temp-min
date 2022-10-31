import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Minimum',
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: const MyHomePage(title: 'Temperature minimum'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<TimeOfDay> _wakes = [];

  @override
  void initState() {
    loadStoredWakes();
    super.initState();
  }

  Future<void> loadStoredWakes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedWakes = prefs.getStringList('wakes') ?? [];
    List<TimeOfDay> parsedWakes = storedWakes.map((w) => strToToD(w)).toList();

    setState(() {
      _wakes = parsedWakes;
    });
  }

  Future<void> setStoredWakes(List<TimeOfDay> wakes) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> parsedWakes = wakes.map((w) => strFromToD(context, w)).toList();
    prefs.setStringList('wakes', parsedWakes);
  }

  Future<void> _showTimePicker() async {
    TimeOfDay? selectedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    if (selectedTime != null) {
      _setWake(selectedTime);
    }
  }

  void _setWake(TimeOfDay time) {
    _setWakes(finiteAddToList(_wakes, time));
  }

  void _setWakes(List<TimeOfDay> wakes) {
    setStoredWakes(wakes);
    setState(() {
      _wakes = wakes;
    });
  }

  void _resetWakes() {
    _setWakes([]);
  }

  void _confirmResetWakes(BuildContext context) async {
    Widget cancelButton = OutlinedButton(
      child: const Text("Cancel"),
      onPressed: () => Navigator.of(context).pop(),
    );

    Widget confirmButton = ElevatedButton(
      onPressed: () {
        _resetWakes();
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
      child: const Text("Clear"),
    );

    AlertDialog alert = AlertDialog(
      title: const Text("Are you sure?"),
      content: const Text("Do you want to clear all recent wake up times?"),
      actions: [
        cancelButton,
        confirmButton,
      ],
    );

    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var innerPad = const EdgeInsets.all(8.0);

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
        padding: innerPad * 2,
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
            // Column is also a layout widget. It takes a list of children and
            // arranges them vertically. By default, it sizes itself to fit its
            // children horizontally, and tries to be as tall as its parent.
            //
            // Invoke "debug painting" (press "p" in the console, choose the
            // "Toggle Debug Paint" action from the Flutter Inspector in Android
            // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
            // to see the wireframe for each widget.
            //
            // Column has various properties to control how it sizes itself and
            // how it positions its children. Here we use mainAxisAlignment to
            // center the children vertically; the main axis here is the vertical
            // axis because Columns are vertical (the cross axis would be
            // horizontal).
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              if (_wakes.isNotEmpty)
                Padding(
                  padding: innerPad,
                  child: TemperatureMinimum(_wakes),
                ),
              Padding(
                padding: innerPad,
                child: ElevatedButton(
                  onPressed: _showTimePicker,
                  child: const Text('Add latest wake time'),
                ),
              ),
              if (_wakes.isNotEmpty)
                Padding(
                  padding: innerPad,
                  child: RecentWakes(_wakes, () => _confirmResetWakes(context)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class TemperatureMinimum extends StatelessWidget {
  final List<TimeOfDay> wakes;
  const TemperatureMinimum(this.wakes, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      strFromToD(context, calcTempMin(wakes)),
      style: Theme.of(context).textTheme.headline2,
      textAlign: TextAlign.center,
    );
  }
}

class RecentWakes extends StatelessWidget {
  final List<TimeOfDay> wakes;
  final VoidCallback onClear;

  const RecentWakes(this.wakes, this.onClear, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Recent: '),
          Text(
            wakes.map((w) => strFromToD(context, w)).join(', '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(width: 16),
        ],
      ),
      const SizedBox(height: 8),
      OutlinedButton(
        onPressed: onClear,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.red,
          textStyle: Theme.of(context).textTheme.bodySmall,
        ),
        child: const Text('Clear recent'),
      ),
    ]);
  }
}
