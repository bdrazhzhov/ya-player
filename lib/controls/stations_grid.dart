import 'package:flutter/material.dart';
import 'package:ya_player/app_state.dart';

import '/helpers/nav_keys.dart';
import '/pages/genre_page.dart';
import '/helpers/custom_sliver_grid_delegate_extent.dart';
import '/models/music_api/station.dart';
import '/services/service_locator.dart';
import 'station_genre.dart';

class StationsGrid extends StatelessWidget {
  final List<Station> stations;
  final _appState = getIt<AppState>();

  StationsGrid({super.key, required this.stations});

  static const double _maxWidth = 412;

  @override
  Widget build(BuildContext context) {
    return SliverGrid.builder(
      itemCount: stations.length,
      gridDelegate: CustomSliverGridDelegateExtent(
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        maxCrossAxisExtent: _maxWidth,
        height: 50
      ),
      itemBuilder: (BuildContext context, int index) {
        final station = stations[index];

        return GestureDetector(
          onTap: () async {
            if(station.subStations.isNotEmpty){
              await NavKeys.mainNav.currentState!.push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => GenrePage(genre: station),
                  reverseTransitionDuration: Duration.zero,
                )
              );
            }
            else {
              _appState.playStation(station);
            }
          },
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: StationGenre(station)
          )
        );
      },
    );
  }
}
