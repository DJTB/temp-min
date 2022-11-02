import 'package:flutter/material.dart';

import '../utils.dart';

typedef OnResetSingleType = void Function(int wakeIndex);

class RecentWakes extends StatelessWidget {
  final List<TimeOfDay> wakes;
  final VoidCallback onResetAll;
  final OnResetSingleType onResetSingle;

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
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent wakes',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
            IconButton(
              tooltip: 'Remove all',
              onPressed: onResetAll,
              icon: Icon(Icons.clear_all_rounded, color: Colors.red[400]),
            )
          ],
        ),
        ...wakes.map(
          (w) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero, // we have content padding externally already
            minLeadingWidth: 0, // defaults to 40 which is a huge gap between icon -> text
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
      ],
    );
  }
}
