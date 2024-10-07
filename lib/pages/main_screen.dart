import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../helpers/app_route_observer.dart';

import 'home_page.dart';
import 'podcasts_books_page.dart';
import '../app_state.dart';
import '../models/music_api/search.dart';
import '../music_api.dart';
import '../services/service_locator.dart';
import 'albums_page.dart';
import 'artists_page.dart';
import 'playlists_page.dart';
import 'queue_page.dart';
import 'search_results_page.dart';
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
  final _appState = getIt<AppState>();
  final _searchTextController = TextEditingController();

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
                case '/queue':
                  String? queueName = settings.arguments as String;
                  page = QueuePage(queueName: queueName);
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

  List<Widget> _createSearch(BuildContext context) {
    final theme = Theme.of(context);

    return [
      if(isSearching) ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 16.0,
            sigmaY: 16.0,
          ),
          child: Container(color: Colors.black.withOpacity(.3)),
        ),
      ),
      if(isSearching) Container(
        padding: const EdgeInsets.only(top: 136, left: 16),
        child: ValueListenableBuilder(
          valueListenable: _appState.searchSuggestionsNotifier,
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
                      _searchTextController.text = entry;
                    });
                    _appState.searchResult(entry);
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
          valueListenable: _appState.searchSuggestionsNotifier,
          builder: (_, suggestions, __) {
            if(!isSearching || suggestions?.best == null) return Container();

            final BestSuggestion best = suggestions!.best!;
            return Row(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  child: CachedNetworkImage(
                    width: 50,
                    height: 50,
                    imageUrl: MusicApi.imageUrl(best.imageUrl, '50x50').toString()
                  ),
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
          controller: _searchTextController,
          decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchTextController.clear();
                  isSearching = false;
                  setState(() {});
                  _appState.searchSuggestionsNotifier.value = null;
                },
              )
          ),
          onChanged: (String value) {
            if(value.isEmpty) {
              setState(() { isSearching = false; });
              _appState.searchSuggestionsNotifier.value = null;
            }
            else if(!isSearching && value.isNotEmpty) {
              setState(() { isSearching = true; });
            }

            if(isSearching && value.length >= 3) {
              _appState.searchSuggestions(value);
            }
          },
        ),
      ),
    ];
  }
}
