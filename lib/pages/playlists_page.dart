import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '/controls/playlist_card.dart';
import '/helpers/custom_sliver_grid_delegate_extent.dart';
import '/l10n/app_localizations.dart';
import '/models/music_api/playlist.dart';
import '/services/app_state.dart';
import '/services/service_locator.dart';
import '../controls/create_playlist_button.dart';
import '../helpers/nav_keys.dart';
import 'page_base.dart';
import 'playlist_page.dart';

class PlaylistsPage extends StatelessWidget {
  static const _itemWidth = 200.0;

  PlaylistsPage({super.key});

  final _appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageBase(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 25, bottom: 50),
          sliver: SliverAppBar(
            // leading: const SizedBox.shrink(),
            automaticallyImplyLeading: false,
            title: Text(
              AppLocalizations.of(context)!.page_playlists,
              style: theme.textTheme.displayMedium,
            ),
            pinned: true,
            backgroundColor: theme.colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            actions: [
              CreatePlaylistButton(
                onCreated: (Playlist playlist) {
                  NavKeys.mainNav.currentState!.push(
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => PlaylistPage(
                        uid: playlist.uid,
                        kind: playlist.kind,
                      ),
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        ValueListenableBuilder<List<Playlist>>(
          valueListenable: _appState.playlistsNotifier,
          builder: (_, playlists, __) {
            return SliverLayoutBuilder(
              builder: (_, SliverConstraints sliverConstraints) {
                final constraints = sliverConstraints.asBoxConstraints();
                final spacing = 12.0;

                if (constraints.maxWidth <
                    spacing * (playlists.length - 1) +
                        playlists.length * _itemWidth) {
                  return SliverGrid.builder(
                    itemCount: playlists.length,
                    gridDelegate: CustomSliverGridDelegateExtent(
                      crossAxisSpacing: spacing,
                      maxCrossAxisExtent: _itemWidth,
                      height: _itemWidth + 60,
                    ),
                    itemBuilder: (_, index) =>
                        PlaylistCard(playlists[index], width: _itemWidth),
                  );
                }

                return SliverToBoxAdapter(
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: playlists
                        .map((playlist) =>
                            PlaylistCard(playlist, width: _itemWidth))
                        .toList(),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
