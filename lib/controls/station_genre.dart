import 'package:flutter/material.dart';

import '/models/music_api/station.dart';
import 'station/station_circle.dart';

class StationGenre extends StatelessWidget {
  final Station station;

  const StationGenre(this.station, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        StationCircle(
          dimension: 50,
          imageDimension: 30,
          imageSourceDimension: 30,
          station: station
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    station.name,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if(station.subStations.isNotEmpty) const Icon(Icons.arrow_forward_ios, size: 14)
              ],
            ),
          ),
        )
      ],
    );
  }
}
