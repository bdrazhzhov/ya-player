import 'package:flutter/material.dart';

import '/helpers/nav_keys.dart';
import '/l10n/app_localizations.dart';
import '/models/music_api/playlist.dart';
import '/models/music_api/track.dart';
import '/pages/album_page.dart';
import '/pages/artist_page.dart';
import '/pages/playlist_page.dart';
import '/services/app_state.dart';
import '/services/music_api.dart';
import '/services/service_locator.dart';
import 'context_menu/context_menu.dart';
import 'context_menu/context_menu_item.dart';

enum TrackActionType {
  download,
  radio,
  addToPlaylist,
  toAlbum,
  toArtists,
  share,
  remove
}

class TrackActions extends StatelessWidget {
  final Track track;
  final Object? playContext;
  final int trackIndex;

  final _appState = getIt<AppState>();
  final _musicApi = getIt<MusicApi>();

  TrackActions(
      {super.key, required this.track, this.playContext, this.trackIndex = 0});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ContextMenu(
      items: [
        MenuItem(
          label: l10n.track_download,
          icon: Icons.download,
        ),
        MenuItem(
          label: l10n.track_radio,
          icon: Icons.radio_outlined,
          onTap: () {
            _appState.playObjectStation(track.stationId());
          },
        ),
        MenuItem(
          label: l10n.track_addToPlaylist,
          icon: Icons.add,
          items: _buildPlaylists(track, l10n),
        ),
        MenuItem(
          label: l10n.track_goToAlbum,
          icon: Icons.album,
          onTap: () {
            NavKeys.mainNav.currentState!.push(PageRouteBuilder(
              pageBuilder: (_, __, ___) => AlbumPage(track.firstAlbumId),
              reverseTransitionDuration: Duration.zero,
            ));
          },
        ),
        _buildArtistMenuItem(l10n),
        MenuItem(label: l10n.track_share, icon: Icons.share),
        MenuItem(label: l10n.track_remove, icon: Icons.clear),
        if (playContext is Playlist &&
            _appState.isPlaylistEditable(playContext as Playlist))
          MenuItem(
            label: l10n.playlist_remove_from,
            icon: Icons.remove_circle_outline,
            onTap: () async {
              final playlist = playContext as Playlist;
              _appState.deletePlaylistTracks(playlist, [trackIndex]);
            },
          ),
      ],
      child: Icon(Icons.more_horiz),
    );
  }

  MenuItem _buildArtistMenuItem(AppLocalizations l10n) {
    MenuItem artistsMenuItem;
    if (track.artists.length > 1) {
      artistsMenuItem = MenuItem(
        label: l10n.track_goToArtists(track.artists.length),
        icon: Icons.person,
        items: track.artists.map((artist) {
          return MenuItem(
            label: artist.name,
            onTap: () {
              NavKeys.mainNav.currentState!.push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => ArtistPage(artistId: artist.id),
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
        onTap: () {
          NavKeys.mainNav.currentState!.push(PageRouteBuilder(
            pageBuilder: (_, __, ___) =>
                ArtistPage(artistId: track.artists.first.id),
            reverseTransitionDuration: Duration.zero,
          ));
        },
      );
    }

    return artistsMenuItem;
  }

  List<MenuItem> _buildPlaylists(Track track, AppLocalizations l10n) {
    final playlists = getIt<AppState>().playlistsNotifier.value.map((playlist) {
      return MenuItem(
        label: playlist.title,
        onTap: () async {
          await getIt<MusicApi>().insertPlaylistTracks(playlist, [track]);
          await getIt<AppState>().requestPlaylists();
        },
      );
    }).toList();

    final newPlaylistItem = MenuItem(
        label: l10n.playlist_create,
        icon: Icons.add,
        onTap: () async {
          final Playlist newPlaylist =
              await _musicApi.createPlaylist(l10n.playlist_new);
          await _musicApi.insertPlaylistTracks(newPlaylist, [track]);
          _appState.requestPlaylists();
          NavKeys.mainNav.currentState!.push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => PlaylistPage(
              uid: newPlaylist.uid,
              kind: newPlaylist.kind,
            ),
            reverseTransitionDuration: Duration.zero,
          ));
        });
    playlists.insert(0, newPlaylistItem);

    return playlists;
  }
}
