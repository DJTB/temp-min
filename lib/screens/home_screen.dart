import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../globals.dart';
import '../utils.dart';
import '../widgets/recent_wakes.dart';
import '../widgets/temperature_minimum.dart';

const innerPad = EdgeInsets.all(Globals.padding);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});
  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TimeOfDay> _wakes = [];

  @override
  void initState() {
    loadStoredWakes();
    super.initState();
  }

  Future<void> loadStoredWakes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> storedWakes = prefs.getStringList('wakes') ?? [];
    List<TimeOfDay> parsedWakes = parseToTimeOfDay(storedWakes);

    setState(() {
      _wakes = parsedWakes;
    });
  }

  Future<void> setStoredWakes(List<TimeOfDay> wakes) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> parsedWakes = parseFromTimeOfDay(wakes);
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
    final shouldRemoveAll = wakeIndex is! int;
    final confirmText = shouldRemoveAll
        ? RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyText1,
              children: const [
                TextSpan(text: "Do you want to remove "),
                TextSpan(
                    text: 'all',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    )),
                TextSpan(text: ' recent wake up times?'),
              ],
            ),
          )
        : const Text('Do you want to remove this wake up time?');

    Widget confirmButton = TextButton(
      onPressed: () {
        shouldRemoveAll ? _resetWakes() : _resetWake(wakeIndex);
        Navigator.of(context).pop();
      },
      style: TextButton.styleFrom(foregroundColor: Colors.red[400]),
      child: const Text("Remove"),
    );

    Widget cancelButton = TextButton(
      onPressed: () => Navigator.of(context).pop(),
      child: const Text("Cancel"),
    );

    showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text("Are you sure?"),
        content: confirmText,
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
              if (_wakes.isNotEmpty) ...[
                const Divider(),
                Expanded(
                  child: RecentWakes(
                    wakes: _wakes,
                    onResetAll: () => _confirmResetWakes(context),
                    onResetSingle: (int wakeIndex) => _confirmResetWakes(context, wakeIndex),
                  ),
                )
              ],
            ],
          ),
        ),
      ),
    );
  }
}
