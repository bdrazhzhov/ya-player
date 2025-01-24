import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ya_player/pages/feed_promotions_page.dart';
import 'package:ya_player/pages/genres_tree_page.dart';

import '/app_state.dart';
import '/controls/yandex_image.dart';
import '/helpers/app_route_observer.dart';
import 'home_page.dart';
import 'podcasts_books_page.dart';
import '/models/music_api/search.dart';
import '/services/service_locator.dart';
import 'albums_page.dart';
import 'artists_page.dart';
import 'playlists_page.dart';
import 'queue_page.dart';
import 'search_results_page.dart';
import 'stations_page.dart';
import 'tracks_page.dart';
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
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 56),
          child: Navigator(
            key: NavKeys.mainNav,
            observers: [getIt<AppRouteObserver>()],
            initialRoute: '/',
            onGenerateRoute: (RouteSettings settings){
              Widget page;

              switch(settings.name) {
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
                case '/home':
                  page = HomePage();
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
          ),
        ),
        ..._createSearch(context)
      ],
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

  List<Widget> _createSearch(BuildContext context) {
    final theme = Theme.of(context);

    return [
      if(isSearching) ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16.0,
            sigmaY: 16.0,
          ),
          child: Container(color: theme.colorScheme.surface.withValues(alpha: 76)),
        ),
      ),
      if(isSearching) Container(
        padding: const EdgeInsets.only(top: 136, left: 16),
        child: ValueListenableBuilder(
          valueListenable: appState.searchSuggestionsNotifier,
          builder: (_, suggestions, __) {
            if(!isSearching || suggestions == null) return Container();

            final List<String> entries = suggestions.entries;
            return ListView.builder(
              itemCount: entries.length,
              itemBuilder: (BuildContext context, int index) {
                final String entry = entries[index];

                return ListTile(
                  visualDensity: const VisualDensity(vertical: -4),
                  title: Text(entry),
                  onTap: () {
                    setState(() {
                      isSearching = false;
                      searchTextController.text = entry;
                    });
                    appState.searchResult(entry);
                    NavKeys.mainNav.currentState!.push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => SearchResultsPage(),
                        reverseTransitionDuration: Duration.zero,
                      )
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      if(isSearching) Container(
        height: 116,
        padding: const EdgeInsets.only(top: 66, left: 32, right: 32),
        child: ValueListenableBuilder(
          valueListenable: appState.searchSuggestionsNotifier,
          builder: (_, suggestions, __) {
            if(!isSearching || suggestions?.best == null) return Container();

            final BestSuggestion best = suggestions!.best!;
            return Row(
              children: [
                YandexImage(
                  uriTemplate: best.imageUrl,
                  size: 50,
                  borderRadius: 8
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          best.title,
                          style: theme.textTheme.titleMedium,
                        ),
                        Text(
                          best.type,
                          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            );
          }
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 34, right: 34),
        child: TextField(
          controller: searchTextController,
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  searchTextController.clear();
                  isSearching = false;
                  setState(() {});
                  appState.searchSuggestionsNotifier.value = null;
                },
              )
          ),
          onChanged: (String value) {
            if(value.isEmpty) {
              setState(() { isSearching = false; });
              appState.searchSuggestionsNotifier.value = null;
            }
            else if(!isSearching && value.isNotEmpty) {
              setState(() { isSearching = true; });
            }

            if(isSearching && value.length >= 3) {
              appState.searchSuggestions(value);
            }
          },
        ),
      ),
    ];
  }
}
