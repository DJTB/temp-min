import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'utils.dart';

void main() {
  runApp(const MyApp());
}

EdgeInsets innerPad = const EdgeInsets.all(8.0);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Temperature Minimum',
      theme: ThemeData.light(),
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
    List<String> parsedWakes = wakes.map((w) => strFromToD(w)).toList();
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

  void _resetWake(int wakeIndex) {
    var newWakes = _wakes.toList();
    newWakes.removeAt(wakeIndex);
    _setWakes(newWakes);
  }

  void _resetWakes() {
    _setWakes([]);
  }

  void _confirmResetWakes(BuildContext context, [int? wakeIndex]) async {
    final shouldClearAll = wakeIndex is! int;
    final confirmText =
        "Do you want to clear ${shouldClearAll ? 'all recent wake up times' : 'this wake up time'}?";

    Widget confirmButton = ElevatedButton(
      onPressed: () {
        shouldClearAll ? _resetWakes() : _resetWake(wakeIndex);
        Navigator.of(context).pop();
      },
      style: ElevatedButton.styleFrom(backgroundColor: Colors.red[400]),
      child: const Text("Clear", style: TextStyle(color: Colors.white)),
    );

    Widget cancelButton = OutlinedButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text("Cancel"),
    );

    showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Are you sure?"),
        content: Text(confirmText),
        actions: [
          cancelButton,
          confirmButton,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: innerPad * 2,
        child: Center(
          child: Column(
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
                  style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.white)),
                  child: const Text('Add latest wake-up time'),
                ),
              ),
              if (_wakes.isNotEmpty)
                Expanded(
                  child: Padding(
                    padding: innerPad,
                    child: RecentWakes(
                      wakes: _wakes,
                      onResetAll: () => _confirmResetWakes(context),
                      onResetSingle: (int wakeIndex) => _confirmResetWakes(context, wakeIndex),
                    ),
                  ),
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
      displayTextFromToD(context, calcTempMin(wakes)),
      style: Theme.of(context).textTheme.headline2?.copyWith(color: Colors.black87),
      textAlign: TextAlign.center,
    );
  }
}

typedef OnResetSingle = void Function(int wakeIndex);

class RecentWakes extends StatelessWidget {
  final List<TimeOfDay> wakes;
  final VoidCallback onResetAll;
  final OnResetSingle onResetSingle;

  const RecentWakes({
    required this.wakes,
    required this.onResetAll,
    required this.onResetSingle,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ...wakes.map(
          (w) => ListTile(
            dense: true,
            title: Text(
              displayTextFromToD(context, w),
              style: Theme.of(context).textTheme.headline6,
            ),
            leading: const Icon(
              Icons.access_time_filled,
            ),
            trailing: IconButton(
              onPressed: () => onResetSingle(wakes.indexOf(w)),
              icon: Icon(
                Icons.clear_rounded,
                color: Colors.red[400],
              ),
            ),
          ),
        ),
        Padding(
          padding: innerPad * 2,
          child: OutlinedButton(
            onPressed: onResetAll,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              textStyle: Theme.of(context).textTheme.bodySmall,
            ),
            child: const Text('Clear all'),
          ),
        )
      ],
    );
  }
}
