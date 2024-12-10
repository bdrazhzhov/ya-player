import 'package:flutter/material.dart';

import '/helpers/nav_keys.dart';
import '/pages/genre_page.dart';
import '/helpers/custom_sliver_grid_delegate_extent.dart';
import '/models/music_api/queue.dart';
import '/models/music_api/station.dart';
import '/models/music_api/track.dart';
import '/music_api.dart';
import '/player/playback_queue.dart';
import '/player/player_base.dart';
import '/player/players_manager.dart';
import '/player/queue_factory.dart';
import '/services/service_locator.dart';
import 'station_genre.dart';

class StationsGrid extends StatelessWidget {
  final List<Station> stations;
  final _musicApi = getIt<MusicApi>();
  final _playersManager = getIt<PlayersManager>();

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
              final Iterable<Track> tracks = await _musicApi.stationTacks(station.id, []);
              Queue queue = await QueueFactory.create(tracksSource: (station, tracks));
              final stationsQueue = StationQueue(station: station, initialData: (queue, tracks));
              final player = StationPlayer(queue: stationsQueue);
              _playersManager.setPlayer(player);
              _playersManager.play();
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
