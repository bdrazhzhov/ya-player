import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '/services/app_state.dart';
import '/pages/current_track_page.dart';
import '/services/service_locator.dart';
import 'yandex_image.dart';

class TrackImage extends StatelessWidget {
  final bool isExpandable;
  TrackImage({super.key, required this.isExpandable,});

  final _appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {

    return ValueListenableBuilder(
        valueListenable: _appState.trackNotifier,
        builder: (_, track, __) {
          Widget image = Padding(
            padding: const EdgeInsets.all(2.0),
            child: YandexImage(
              uriTemplate: track?.coverUri,
              width: 50,
            ),
          );

          if(track != null) {
            if(isExpandable) {
              return MouseRegion(
                cursor: SystemMouseCursors.click,
                child: OpenContainer(
                  closedColor: Colors.transparent,
                  closedBuilder: (BuildContext context, void Function() action) {
                    return image;
                  },
                  openBuilder: (BuildContext context, void Function({Object? returnValue}) action) {
                    return CurrentTrackPage();
                  },
                ),
              );
            }
            else {
              return image;
            }
          }
          else {
            return image;
          }
        }
    );
  }
}
