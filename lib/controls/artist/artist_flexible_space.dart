import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

import '/app_state.dart';
import '/services/service_locator.dart';
import '/models/music_api/artist.dart';
import '/controls/yandex_image.dart';

class ArtistFlexibleSpace extends StatelessWidget {
  final LikedArtist artist;
  final _appState = getIt<AppState>();

  ArtistFlexibleSpace({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (settings!.currentExtent == settings.minExtent) {
      return Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: YandexImage(
              uriTemplate: artist.cover?.uri ?? '',
              size: 60,
              borderRadius: 8
            ),
          ),
          Expanded(
            child: Text(
              artist.name,
              style: theme.textTheme.headlineLarge
            )
          ),
          _createActionButtons(l10n)
        ],
      );
    }
    else {
      double infoBlockHeight = settings.currentExtent;
      if (infoBlockHeight < 100) infoBlockHeight = 100;

      return Row(
        children: [
          YandexImage(
            uriTemplate: artist.cover?.uri ?? '',
            size: 200,
            borderRadius: 8
          ),
          const SizedBox(width: 20),
          Flexible(
            child: SizedBox(
              height: infoBlockHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.artist_artist),
                  Text(
                    artist.name,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: theme.textTheme.headlineLarge,
                  ),
                  SizedBox(height: 8),
                  _createActionButtons(l10n)
                ],
              ),
            ),
          )
        ],
      );
    }
  }

  Widget _createActionButtons(AppLocalizations l10n) {
    final extraActions = artist.extraActions.map(
      (e) => _ActionButton(
        icon: Icons.language,
        text: e.title,
        onPressed: () => launchUrl(Uri.parse(e.url)),
      )
    );

    return Row(
      spacing: 8,
      children: [
        _ActionButton(
          icon: Icons.play_arrow,
          text: l10n.artist_play,
          onPressed: () {},
        ),
        _ActionButton(
          icon: Icons.favorite,
          text: l10n.artist_like,
          onPressed: () {},
        ),
        _ActionButton(
          icon: Icons.radio,
          text: l10n.artist_station,
          onPressed: () => _appState.playArtistStation(artist),
        ),
        ...extraActions
      ]
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onPressed;

  const _ActionButton({required this.icon, required this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Row(
        spacing: 8,
        children: [
          Icon(icon),
          Text(text)
        ]
      )
    );
  }
}

