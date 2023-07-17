import 'package:flutter/material.dart';

import 'albums_page.dart';
import 'artists_page.dart';
import 'playlists_page.dart';
import 'stations_page.dart';
import 'tracks_page.dart';
import '../helpers/nav_keys.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavKeys.mainNav,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings){
        Widget page;

        switch(settings.name) {
          case '/tracks':
            page = const TracksPage();
          case '/albums':
            page = AlbumsPage();
          case '/artists':
            page = const ArtistsPage();
          case '/playlists':
            page = const PlaylistsPage();
          case '/stations':
          default:
            page = StationsPage();
        }

        return PageRouteBuilder(pageBuilder: (_, __, ___) => page);
      },
    );
  }
}
