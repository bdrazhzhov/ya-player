
import 'package:flutter/material.dart';

import '/pages/search_page.dart';
import '/app_state.dart';
import '/helpers/app_route_observer.dart';
import 'podcasts_books_page.dart';
import '/services/service_locator.dart';
import 'albums_page.dart';
import 'artists_page.dart';
import 'playlists_page.dart';
import 'queue_page.dart';
import 'stations_page.dart';
import 'tracks_page.dart';
import 'feed_promotions_page.dart';
import 'genres_tree_page.dart';
import 'settings_page.dart';
import '/helpers/nav_keys.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MainScreen();

}

class _MainScreen extends State<MainScreen> {
  bool isSearching = false;
  final appState = getIt<AppState>();
  final searchTextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavKeys.mainNav,
      observers: [getIt<AppRouteObserver>()],
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings){
        Widget page;

        switch(settings.name) {
          case '/search':
            page = SearchPage();
          case '/tracks':
            page = TracksPage();
          case '/albums':
            page = const AlbumsPage();
          case '/artists':
            page = const ArtistsPage();
          case '/playlists':
            page = const PlaylistsPage();
          case '/podcasts_books':
            page = PodcastsBooksPage();
          case '/mix_link':
            final url = settings.arguments as String;
            page = _mixLinkPage(url);
          case '/queue':
            page = QueuePage();
          case '/settings':
            page = const SettingsPage();
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

  Widget _mixLinkPage(String url) {
    final List<String> segments = url.split('/');

    switch(segments[1]) {
      case 'post':
        return FeedPromotionsPage(id: segments[2]);
      case 'tag':
        return GenresTreePage(id: segments[2]);
      default:
        return Text('No route');
    }
  }
}
