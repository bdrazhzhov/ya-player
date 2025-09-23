import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/controls/like_button.dart';
import '/helpers/nav_keys.dart';
import '/models/music_api/search.dart';
import '/pages/artist_page.dart';
import '/services/app_state.dart';
import '/services/preferences.dart';
import '/services/service_locator.dart';
import 'best_result_artist_cover.dart';

class BestResultArtistCard extends StatefulWidget {
  final BestResultArtist bestResult;

  const BestResultArtistCard(this.bestResult, {super.key});

  @override
  State<BestResultArtistCard> createState() => _BestResultArtistCardState();
}

class _BestResultArtistCardState extends State<BestResultArtistCard> {
  final appState = getIt<AppState>();
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            spacing: 12,
            children: [
              BestResultArtistCover(
                bestResult: widget.bestResult.artist,
                isHovered: isHovered,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.bestResult.artist.name),
                    if (widget.bestResult.likesCount != null)
                      _LikesCount(widget.bestResult.likesCount!),
                  ],
                ),
              ),
              LikeButton(
                likeCondition: () => appState.isLikedArtist(widget.bestResult.artist.id),
                onLikeClicked: () => appState.likeArtist(widget.bestResult.artist.id),
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
          pageBuilder: (_, __, ___) => ArtistPage(artistId: widget.bestResult.artist.id),
          reverseTransitionDuration: Duration.zero,
        ));
      },
    );
  }
}

class _LikesCount extends StatelessWidget {
  final int count;
  final _prefs = getIt<Preferences>();

  _LikesCount(this.count);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = NumberFormat.decimalPattern(_prefs.locale.languageCode);

    return Row(
      spacing: 8,
      children: [
        Icon(
          Icons.favorite_border_outlined,
          size: theme.textTheme.bodyMedium?.fontSize,
        ),
        Text(
          fmt.format(count),
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
