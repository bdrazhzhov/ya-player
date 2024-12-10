import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '/models/music_api/queue.dart';
import '/models/music_api/track.dart';
import '/player/playback_queue.dart';
import '/player/player_base.dart';
import '/player/queue_factory.dart';
import '/player/players_manager.dart';
import '/services/service_locator.dart';
import '/helpers/color_extension.dart';
import '/models/music_api/station.dart';
import '/music_api.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final bool isCurrent;
  final double width;

  final _musicApi = getIt<MusicApi>();
  final _playersManager = getIt<PlayersManager>();

  StationCard({
    super.key,
    required this.station,
    required this.isCurrent,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outlineColor = isCurrent ? theme.colorScheme.outline : Colors.transparent;

    return InkResponse(
      onTap: () async {
        final Iterable<Track> tracks = await _musicApi.stationTacks(station.id, []);
        Queue queue = await QueueFactory.create(tracksSource: (station, tracks));
        final stationsQueue = StationQueue(station: station, initialData: (queue, tracks));
        final player = StationPlayer(queue: stationsQueue);

        _playersManager.setPlayer(player);
        _playersManager.play();
      },
      child: Container(
        width: width,
        decoration: BoxDecoration(
          border: Border.all(width: 3, color: outlineColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Flexible(
              child: Container(
                width: width,
                height: width,
                decoration: BoxDecoration(
                  color: station.icon.backgroundColor.toColor(),
                  shape: BoxShape.circle
                ),
                child: Center(
                  child: CachedNetworkImage(
                    width: width / 1.5,
                    height: width / 1.5,
                    fit: BoxFit.fitWidth,
                    imageUrl: MusicApi.imageUrl(station.icon.imageUrl, '150x150').toString(),
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 10),
              child: Text(station.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
