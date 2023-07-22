import 'dart:ui';

import 'package:flutter/material.dart';

import 'albums_page.dart';
import 'artists_page.dart';
import 'playlists_page.dart';
import 'stations_page.dart';
import 'tracks_page.dart';
import '../helpers/nav_keys.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScreen();

}

class _MainScreen extends State<MainScreen> {
  bool isSearching = false;

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
            page = ArtistsPage();
          case '/playlists':
            page = const PlaylistsPage();
          case '/stations':
          default:
            page = StationsPage();
        }

        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return page;
          }
        );
      },
    );
  }
}
