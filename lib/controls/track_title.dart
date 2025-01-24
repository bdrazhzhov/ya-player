import 'package:flutter/material.dart';

import '/helpers/nav_keys.dart';
import '/models/music_api/track.dart';
import '/pages/album_page.dart';

class TrackTitle extends StatelessWidget {
  final Track track;

  const TrackTitle({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        NavKeys.mainNav.currentState!.push(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => AlbumPage(track.firstAlbumId),
            reverseTransitionDuration: Duration.zero,
          )
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Text(
          track.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
          softWrap: false,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
