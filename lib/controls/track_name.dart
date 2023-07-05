import 'package:flutter/material.dart';

import '../app_state.dart';

class TrackName extends StatelessWidget {
  const TrackName({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: appState.trackNotifier,
        builder: (_, value, __) {
          if(value != null) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(value.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0),
                    child: Text(value.artists.first.name),
                  )
                ]);
          }
          else {
            return const SizedBox(width: 1, height: 1);
          }
        }
    );
  }
}
