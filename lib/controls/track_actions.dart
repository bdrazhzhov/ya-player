import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';

import '/services/service_locator.dart';
import '/l10n/app_localizations.dart';
import '/services/app_state.dart';
import '/helpers/nav_keys.dart';
import '/models/music_api/track.dart';
import '/pages/album_page.dart';
import '/pages/artist_page.dart';

enum TrackActionType { download, radio, addToPlaylist, toAlbum, toArtists, share, remove }

class TrackActions extends StatelessWidget {
  final Track track;
  final _appState = getIt<AppState>();

  TrackActions({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showContextMenu(context, contextMenu: _buildMenu(context));
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Icon(Icons.more_horiz),
      ),
    );
  }

  ContextMenu _buildMenu(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final l10n = AppLocalizations.of(context)!;

    return ContextMenu(
      entries: [
        MenuItem(
          label: l10n.track_download,
          icon: Icons.download,
          enabled: false,
          onSelected: () {
            // Handle download action
          },
        ),
        MenuItem(
          label: l10n.track_radio,
          icon: Icons.radio_outlined,
          onSelected: () {
            _appState.playObjectStation(track);
          },
        ),
        MenuItem(
          label: l10n.track_addToPlaylist,
          icon: Icons.add,
          enabled: false,
          onSelected: () {
            // Handle add to playlist action
          },
        ),
        MenuItem(
          label: l10n.track_goToAlbum,
          icon: Icons.album,
          onSelected: () {
            NavKeys.mainNav.currentState!.push(PageRouteBuilder(
              pageBuilder: (_, __, ___) => AlbumPage(track.firstAlbumId),
              reverseTransitionDuration: Duration.zero,
            ));
          },
        ),
        _buildArtistMenuItem(context),
        MenuItem(label: l10n.track_share, icon: Icons.share, enabled: false),
        MenuItem(label: l10n.track_remove, icon: Icons.clear, enabled: false),
      ],
      position: renderBox.localToGlobal(Offset.zero),
      padding: const EdgeInsets.all(8.0),
    );
  }

  MenuItem _buildArtistMenuItem(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    MenuItem artistsMenuItem;
    if (track.artists.length > 1) {
      artistsMenuItem = MenuItem.submenu(
        label: l10n.track_goToArtists(track.artists.length),
        icon: Icons.person,
        items: track.artists.map((artist) {
          return MenuItem(
            value: artist,
            label: artist.name,
            onSelected: () {
              NavKeys.mainNav.currentState!.push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => ArtistPage(artist),
                reverseTransitionDuration: Duration.zero,
              ));
            },
          );
        }).toList(),
      );
    } else {
      artistsMenuItem = MenuItem(
        label: l10n.track_goToArtists(track.artists.length),
        icon: Icons.person,
        onSelected: () {
          NavKeys.mainNav.currentState!.push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => ArtistPage(track.artists.first),
            reverseTransitionDuration: Duration.zero,
          ));
        },
      );
    }

    return artistsMenuItem;
  }
}
