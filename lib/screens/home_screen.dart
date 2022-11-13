import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/wakes_cubit.dart';
import '../globals.dart';
import '../widgets/recent_wakes.dart';
import '../widgets/temperature_minimum.dart';

const innerPad = EdgeInsets.all(Globals.padding);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WakesCubit([]),
      child: const HomeScreenView(),
    );
  }
}

class HomeScreenView extends StatelessWidget {
  const HomeScreenView({super.key});

  Future<void> _showTimePicker(BuildContext context, void Function(TimeOfDay) onAdd) async {
    TimeOfDay? selectedTime = await showTimePicker(
      initialTime: TimeOfDay.now(),
      context: context,
    );

    if (selectedTime != null) {
      onAdd(selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          Globals.appTitle,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Padding(
        padding: innerPad * 2,
        child: Center(
          child: BlocBuilder<WakesCubit, Wakes>(builder: (context, state) {
            var hasWakes = state.isNotEmpty;

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                if (hasWakes)
                  Padding(
                    padding: innerPad,
                    child: TemperatureMinimum(state),
                  ),
                Padding(
                  padding: innerPad,
                  child: ElevatedButton(
                    onPressed: () => _showTimePicker(context, context.read<WakesCubit>().addWake),
                    style: ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.white)),
                    child: const Text('Add latest wake-up time'),
                  ),
                ),
                if (hasWakes) ...[
                  const Divider(),
                  Expanded(
                      child: RecentWakes(
                    wakes: state,
                    onResetAll: () => confirmResetWakes(context),
                    onResetSingle: (int wakeIndex) => confirmResetWakes(context, wakeIndex),
                  ))
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}

void confirmResetWakes(BuildContext context, [int? wakeIndex]) async {
  final shouldRemoveAll = wakeIndex is! int;

  void handleConfirm() {
    shouldRemoveAll
        ? context.read<WakesCubit>().resetAll()
        : context.read<WakesCubit>().resetWake(wakeIndex);
    Navigator.of(context).pop();
  }

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
    onPressed: handleConfirm,
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
