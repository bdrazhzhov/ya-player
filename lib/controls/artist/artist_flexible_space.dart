import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '/l10n/app_localizations.dart';
import '/controls/flexible_space.dart';
import '/player/players_manager.dart';
import '/models/music_api/artist_info.dart';
import '/app_state.dart';
import '/services/service_locator.dart';
import '/controls/like_button.dart';

class ArtistFlexibleSpace extends StatelessWidget {
  final ArtistInfo artistInfo;
  final _appState = getIt<AppState>();
  final _player = getIt<PlayersManager>();

  ArtistFlexibleSpace({super.key, required this.artistInfo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FlexibleSpace(
      imageUrl: artistInfo.artist.cover?.uri,
      type: FlexibleSpaceType.artist,
      title: artistInfo.artist.name,
      actions: _createActionButtons(l10n)
    );
  }

  Widget _createActionButtons(AppLocalizations l10n) {
    final extraActions = artistInfo.artist.extraActions.map(
      (e) {
        var icon = Icons.language;

        switch(e.type) {
          case 'donation':
            icon = Icons.monetization_on;
            break;
        }

        return IconButton(
          icon: Icon(icon),
          tooltip: e.title,
          onPressed: () => launchUrl(Uri.parse(e.url)),
        );
      }
    );

    return Row(
      spacing: 8,
      children: [
        IconButton(
          icon: Icon(Icons.play_arrow),
          tooltip: l10n.artist_play,
          onPressed: () async {
            await _appState.playContent(artistInfo, artistInfo.popularTracks, 0);
            await _player.play(0);
          },
        ),
        LikeButton(
          likeCondition: () => _appState.isLikedArtist(artistInfo.artist),
          onLikeClicked: () => _appState.likeArtist(artistInfo.artist),
        ),
        IconButton(
          icon: Icon(Icons.radio),
          tooltip: l10n.artist_station,
          onPressed: () => _appState.playObjectStation(artistInfo.artist),
        ),
        ...extraActions
      ]
    );
  }
}
