import 'package:flutter/material.dart';

import '/app_state.dart';
import '/services/service_locator.dart';
import '/l10n/app_localizations.dart';
import '/models/music_api/artist.dart';
import '/pages/artist_page.dart';
import 'yandex_image.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;
  final double width;

  ArtistCard(this.artist, this.width, {super.key});

  final _appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkResponse(
      onTap: () {
        Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ArtistPage(artist),
              reverseTransitionDuration: Duration.zero,
            )
        );
      },
      child: Container(
        constraints: BoxConstraints(maxWidth: width),
        child: Column(
          children: [
            if(artist.cover != null)
              YandexImage(
                uriTemplate: artist.cover?.uri,
                size: width,
                borderRadius: 8
              ),
            Text(
              artist.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            if(artist.counts != null)
              Text(
                AppLocalizations.of(context)!.tracks_count(artist.counts!.tracks),
                style: TextStyle(fontSize: theme.textTheme.labelMedium?.fontSize),
              ),
            Text(
              artist.genres.map((id) => _appState.getGenreTitle(id)).join(', '),
              style: TextStyle(fontSize: theme.textTheme.labelMedium?.fontSize),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            )
          ],
        ),
      ),
    );
  }
}
