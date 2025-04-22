import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '/l10n/app_localizations.dart';
import '../helpers/custom_sliver_grid_delegate_extent.dart';
import '/models/music_api/playlist.dart';
import '/services/app_state.dart';
import '/controls/playlist_card.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  final appState = getIt<AppState>();
  static const _itemWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    return PageBase(
      title: AppLocalizations.of(context)!.page_playlists,
      slivers: [ValueListenableBuilder<List<Playlist>>(
        valueListenable: appState.playlistsNotifier,
        builder: (_, playlists, __) {
          return SliverLayoutBuilder(
            builder: (_, SliverConstraints sliverConstraints) {
              final constraints = sliverConstraints.asBoxConstraints();
              final spacing = 12.0;

              if(constraints.maxWidth < spacing * (playlists.length - 1) + playlists.length * _itemWidth)
              {
                return SliverGrid.builder(
                  itemCount: playlists.length,
                  gridDelegate: CustomSliverGridDelegateExtent(
                    crossAxisSpacing: spacing,
                    maxCrossAxisExtent: _itemWidth,
                    height: _itemWidth + 60
                  ),
                  itemBuilder: (_, index) => PlaylistCard(playlists[index], width: _itemWidth),
                );
              }

              return SliverToBoxAdapter(
                child: Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: playlists.map((playlist) => PlaylistCard(playlist, width: _itemWidth)).toList(),
                ),
              );
            },
          );
        }
      )],
    );
  }
}

