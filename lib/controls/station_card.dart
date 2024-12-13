import 'package:flutter/material.dart';

import '/models/music_api/queue.dart';
import '/models/music_api/track.dart';
import '/player/playback_queue.dart';
import '/player/player_base.dart';
import '/player/queue_factory.dart';
import '/player/players_manager.dart';
import '/services/service_locator.dart';
import '/models/music_api/station.dart';
import '/music_api.dart';
import 'station/station_circle.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final double width;

  final _musicApi = getIt<MusicApi>();
  final _playersManager = getIt<PlayersManager>();

  StationCard({
    super.key,
    required this.station,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () async {
        final Iterable<Track> tracks = await _musicApi.stationTacks(station.id, []);
        Queue queue = await QueueFactory.create(tracksSource: (station, tracks));
        final stationsQueue = StationQueue(station: station, initialData: (queue, tracks));
        final player = StationPlayer(queue: stationsQueue);

        _playersManager.setPlayer(player);
        _playersManager.play();
      },
      child: Column(
        children: [
          Flexible(
            child: StationCircle(
              dimension: width,
              imageDimension: 150 / 1.3,
              imageSourceDimension: 150,
              station: station
            )
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 10),
            child: Text(station.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }
}
