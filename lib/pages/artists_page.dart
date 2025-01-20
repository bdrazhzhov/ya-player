import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/helpers/custom_sliver_grid_delegate_extent.dart';
import '/models/music_api/artist.dart';
import '/pages/page_base.dart';
import '/app_state.dart';
import '/controls/artist_card.dart';
import '/services/service_locator.dart';

class ArtistsPage extends StatelessWidget {
  const ArtistsPage({super.key});

  static const _itemWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    final appState = getIt<AppState>();

    return PageBase(
      title: AppLocalizations.of(context)!.page_artists,
      slivers: [ValueListenableBuilder<List<Artist>>(
        valueListenable: appState.artistsNotifier,
        builder: (_, artists, __) {
          return SliverLayoutBuilder(
            builder: (_, SliverConstraints sliverConstraints) {
              final constraints = sliverConstraints.asBoxConstraints();
              final spacing = 12.0;

              if(constraints.maxWidth < spacing * (artists.length - 1) + artists.length * _itemWidth)
              {
                return SliverGrid(
                  gridDelegate: CustomSliverGridDelegateExtent(
                    crossAxisSpacing: spacing,
                    maxCrossAxisExtent: _itemWidth,
                    height: _itemWidth + 60
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (_, index) => ArtistCard(artists[index], _itemWidth),
                    childCount: artists.length
                  )
                );
              }
              else {
                return SliverToBoxAdapter(
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: artists.map((artist) => ArtistCard(artist, _itemWidth)).toList(),
                  )
                );
              }
            },
          );
        }
      )]
    );
  }
}
