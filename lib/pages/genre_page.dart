import 'package:flutter/material.dart';

import '/controls/stations_grid.dart';
import '/models/music_api/station.dart';
import 'page_base.dart';

class GenrePage extends StatelessWidget {
  final Station genre;

  const GenrePage({super.key, required this.genre});

  @override
  Widget build(BuildContext context) {
    return PageBase(slivers: [
      StationsGrid(stations: genre.subStations),
    ]);
  }
}
