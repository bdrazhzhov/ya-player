import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:ya_player/services/music_api.dart';

import '/models/music_api/playlist.dart';
import '/services/app_state.dart';
import '/services/service_locator.dart';
import '/helpers/nav_keys.dart';
import '/l10n/app_localizations.dart';
import '/models/music_api/track.dart';
import '/pages/album_page.dart';
import '/pages/artist_page.dart';

ContextMenu trackMenu(BuildContext context, Track track, {Playlist? playlist}) {
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
          getIt<AppState>().playObjectStation(track);
        },
      ),
      MenuItem.submenu(
        label: l10n.track_addToPlaylist,
        icon: Icons.add,
        items: _buildPlaylists(track),
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
      _buildArtistMenuItem(context, track),
      MenuItem(label: l10n.track_share, icon: Icons.share, enabled: false),
      MenuItem(label: l10n.track_remove, icon: Icons.clear, enabled: false),
      if(playlist != null)
        MenuItem(label: 'Delete from playlist', icon: Icons.delete, onSelected: () {
          // getIt<MusicApi>().removePlaylistTracks(playlist, [track]).then((_) {
          //   getIt<AppState>().requestPlaylists();
          // });
        }),
    ],
    position: renderBox.localToGlobal(Offset.zero),
    padding: const EdgeInsets.all(8.0),
  );
}

MenuItem _buildArtistMenuItem(BuildContext context, Track track) {
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

List<MenuItem> _buildPlaylists(Track track) {
  return getIt<AppState>().playlistsNotifier.value.map((playlist){
    return MenuItem(
      value: playlist,
      label: playlist.title,
      onSelected: () async {
        await getIt<MusicApi>().insertPlaylistTracks(playlist, [track]);
        await getIt<AppState>().requestPlaylists();
      },
    );
  }).toList();
}
