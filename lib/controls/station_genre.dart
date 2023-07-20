import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../utils/color_extension.dart';
import '../models/music_api/station.dart';
import '../music_api.dart';

class StationGenre extends StatelessWidget {
  final Station station;

  const StationGenre(this.station, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: station.icon.backgroundColor.toColor(),
                shape: BoxShape.circle
            ),
            child: Center(
              child: CachedNetworkImage(
                width: 30,
                height: 30,
                fit: BoxFit.fitWidth,
                imageUrl: MusicApi.imageUrl(station.icon.imageUrl, '100x100').toString(),
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 240),
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
      ),
    );
  }
}
