import 'package:flutter/material.dart';

import '/services/app_state.dart';
import '/services/service_locator.dart';
import '/models/music_api/station.dart';
import 'station_circle.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final double width;

  final _appState = getIt<AppState>();

  StationCard({
    super.key,
    required this.station,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: () => _appState.playStation(station),
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
