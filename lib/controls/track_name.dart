import 'package:flutter/material.dart';

import '../app_state.dart';
import '../services/service_locator.dart';

class TrackName extends StatelessWidget {
  TrackName({super.key,});

  final AppState _appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _appState.trackNotifier,
        builder: (_, value, __) {
          if(value != null) {
            return Container(
              constraints: const BoxConstraints(maxWidth: 250),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        value.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6.0),
                      child: Text(
                        value.artists.map((e) => e.name).join(', '),
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ]),
            );
          }
          else {
            return const SizedBox(width: 1, height: 1);
          }
        }
    );
  }
}
