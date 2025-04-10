import 'package:flutter/material.dart';
import 'package:ya_player/services/service_locator.dart';

import '/l10n/app_localizations.dart';
import '/app_state.dart';
import '/helpers/nav_keys.dart';
import '/models/music_api/track.dart';
import '/pages/album_page.dart';
import '/pages/artist_page.dart';

enum TrackActionType {download, radio, addToPlaylist, toAlbum, toArtists, share, remove}

class TrackActions extends StatelessWidget {
  final Track track;
  final _appState = getIt<AppState>();

  TrackActions({super.key, required this.track});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    PopupMenuEntry<Object> artistsMenuItem;
    if(track.artists.length > 1) {
      artistsMenuItem = PopupMenuItem(
        child: PopupMenuButton<Object>(
          padding: EdgeInsets.zero,
          menuPadding: EdgeInsets.zero,
          popUpAnimationStyle: AnimationStyle.noAnimation,
          offset: Offset(120, 0),
          tooltip: '',
          itemBuilder: (BuildContext context) => track.artists.map((artist){
            return PopupMenuItem(
              value: artist,
              height: 40,
              child: Text(artist.name),
              onTap: (){
                NavKeys.mainNav.currentState!.push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => ArtistPage(artist),
                    reverseTransitionDuration: Duration.zero,
                  )
                );
              },
            );
          }).toList(),
          onSelected: (value){

          },
          child: Row(
            spacing: 8,
            children: [
              Icon(Icons.person, size: 18),
              Text(l10n.track_goToArtists(track.artists.length)),
              Icon(Icons.arrow_forward_ios, size: 18)
            ],
          ),
        ),
      );
    }
    else {
      artistsMenuItem = buildMenuItem(
        text: l10n.track_goToArtists(track.artists.length),
        action: TrackActionType.toArtists,
        icon: Icons.person,
        onTap: (){
          NavKeys.mainNav.currentState!.push(
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => ArtistPage(track.artists.first),
              reverseTransitionDuration: Duration.zero,
            )
          );
        }
      ); 
    }

    return PopupMenuButton<Object>(
      icon: Icon(Icons.more_horiz),
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      popUpAnimationStyle: AnimationStyle.noAnimation,
      offset: Offset(40, 0),
      tooltip: '',
      itemBuilder: (BuildContext context) => [
        buildMenuItem(
          text: l10n.track_download,
          action: TrackActionType.download,
          icon: Icons.download
        ),
        buildMenuItem(
          text: l10n.track_radio,
          action: TrackActionType.radio,
          icon: Icons.radio_outlined,
          onTap: () {
            _appState.playObjectStation(track);
          }
        ),
        buildMenuItem(
          text: l10n.track_addToPlaylist,
          action: TrackActionType.addToPlaylist,
          icon: Icons.add
        ),
        buildMenuItem(
          text: l10n.track_goToAlbum,
          action: TrackActionType.toAlbum,
          icon: Icons.album,
          onTap: (){
            NavKeys.mainNav.currentState!.push(
              PageRouteBuilder(
                pageBuilder: (_, __, ___) => AlbumPage(track.firstAlbumId),
                reverseTransitionDuration: Duration.zero,
              )
            );
          }
        ),
        artistsMenuItem,
        buildMenuItem(
          text: l10n.track_share,
          action: TrackActionType.share,
          icon: Icons.share
        ),
        buildMenuItem(
          text: l10n.track_remove,
          action: TrackActionType.remove,
          icon: Icons.clear
        ),
      ],
      onSelected: (value){

      },
    );
  }

  PopupMenuItem<Object> buildMenuItem({
    required String text,
    required TrackActionType action,
    required IconData icon,
    void Function()? onTap
  }) {
    return PopupMenuItem(
      onTap: onTap,
      value: action,
      height: 40,
      child: Row(
        spacing: 8,
        children: [
          Icon(icon, size: 18),
          Text(text),
        ],
      ),
    );
  }
}
