import 'package:flutter/material.dart';
import 'package:ya_player/controls/artist/artist_names.dart';
import 'package:ya_player/models/music_api/search.dart';
import 'package:ya_player/pages/album_page.dart';

import '/controls/like_button.dart';
import '/helpers/nav_keys.dart';
import '/l10n/app_localizations.dart';
import '/services/app_state.dart';
import '/services/service_locator.dart';
import 'best_result_album_cover.dart';

class BestResultRecentReleaseCard extends StatefulWidget {
  final BestResultRecentRelease bestResult;

  const BestResultRecentReleaseCard({super.key, required this.bestResult});

  @override
  State<BestResultRecentReleaseCard> createState() =>
      _BestResultRecentReleaseCardState();
}

class _BestResultRecentReleaseCardState
    extends State<BestResultRecentReleaseCard> {
  bool isHovered = false;
  final appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            spacing: 12,
            children: [
              BestResultAlbumCover(
                bestResult: widget.bestResult.album,
                isHovered: isHovered,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.bestResult.album.title),
                    Text(
                      l10n.recent_release,
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                    ArtistNames(artists: widget.bestResult.artists),
                  ],
                ),
              ),
              LikeButton(
                likeCondition: () {
                  return false;
                },
                onLikeClicked: () async {},
              ),
              const Icon(Icons.chevron_right)
            ],
          ),
        ),
        onEnter: (_) {
          isHovered = true;
          setState(() {});
        },
        onExit: (_) {
          isHovered = false;
          setState(() {});
        },
      ),
      onTap: () {
        NavKeys.mainNav.currentState!.push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => AlbumPage(widget.bestResult.album.id),
          reverseTransitionDuration: Duration.zero,
        ));
      },
    );
  }
}
