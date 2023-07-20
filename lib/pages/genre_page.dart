import 'package:flutter/material.dart';

import '../models/music_api/station.dart';
import '../controls/page_base_layout.dart';
import '../controls/station_genre.dart';


class GenrePage extends StatelessWidget {
  final Station genre;

  const GenrePage({
    super.key, required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    return PageBaseLayout(
      title: genre.name,
      body: Wrap(children: genre.subStations.map((station) {
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: StationGenre(station)
        );
      }).toList()),
    );
  }
}
