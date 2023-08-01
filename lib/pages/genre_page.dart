import 'package:flutter/material.dart';

import '../app_state.dart';
import '../models/music_api/station.dart';
import '../controls/station_genre.dart';
import '../services/service_locator.dart';


class GenrePage extends StatelessWidget {
  final Station genre;
  final appState = getIt<AppState>();

  static const double _minWidth = 250;
  static const double _maxWidth = 412;

  GenrePage({
    super.key, required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          int columnsNumber = 3;
          double width = constraints.maxWidth / columnsNumber;

          while(true) {
            if(width < _minWidth) columnsNumber -= 1;
            if(columnsNumber == 0) {
              columnsNumber = 1;
              width = constraints.maxWidth;
              break;
            }
            if(width > _maxWidth) columnsNumber += 1;

            width = constraints.maxWidth / columnsNumber;

            if(columnsNumber == 1 || width >= _minWidth && width <= _maxWidth) break;
          }

          return Wrap(children: genre.subStations.map((station) {
            return Container(
                constraints: BoxConstraints(maxWidth: width),
                padding: const EdgeInsets.all(4.0),
                child: GestureDetector(
                    onTap: (){ appState.playStationTracks(station); },
                    child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: StationGenre(station)
                    )
                )
            );
          }).toList()
          );
        },
      ),
    );
  }
}
