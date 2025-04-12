import 'package:flutter/material.dart';
import 'package:ya_player/controls/app_search_bar.dart';

import '/app_state.dart';
import '/controls/page_block.dart';
import '/models/music_api/block.dart';
import '/services/service_locator.dart';
import '/l10n/app_localizations.dart';
import '/models/music_api/search.dart';
import 'page_base.dart';
import 'search_result_mixed_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool isDefaultView = true;
  SearchFilter? filter;
  late Future<SearchResultMixed> searchResult;
  // final searchTextController = TextEditingController();
  String searchText = '';
  final _appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageBase(
      slivers: [
        buildSearchBar(theme),
        isDefaultView ? buildDefaultView() : SearchResultMixedPage(text: searchText, filter: filter),
      ]
    );
  }

  SliverAppBar buildSearchBar(ThemeData theme) {
    return SliverAppBar(
      leading: const SizedBox.shrink(),
      pinned: true,
      expandedHeight: 124,
      collapsedHeight: 124,
      flexibleSpace: Column(
        children: [
          SizedBox(height: 12),
          AppSearchBar(onChanged: onSearchTextChanged),
          SizedBox(height: 12),
          buildSearchSelector(theme),
        ],
      ),
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
    );
  }

  void onSearchTextChanged(String text) {
    searchText = text;

    if(text.length < 3) {
      if(!isDefaultView) {
        isDefaultView = true;
        setState(() {});
      }

      return;
    }

    isDefaultView = false;
    setState(() {});
  }

  Widget buildDefaultView() {
    return ValueListenableBuilder(
      valueListenable: _appState.landingNotifier,
      builder: (_, List<Block> blocks, __) {
        return SliverList.builder(
          itemCount: blocks.length,
          itemBuilder: (BuildContext context, int index) {
            return Column(
              children: [
                PageBlock(block: blocks[index]),
                const SizedBox(height: 50)
              ],
            );
          }
        );
      },
    );
  }

  Widget buildSearchSelector(ThemeData theme) {
    if(isDefaultView) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context)!;

    List<Widget> items = [OutlinedButton(
      onPressed: (){
        filter = null;
        isDefaultView = false;
        setState(() {});
      },
      // style: filter == null ? style : null,
      style: OutlinedButton.styleFrom(
        side: BorderSide(width: 2, color: filter == null ? theme.colorScheme.primary : Colors.transparent),
        foregroundColor: theme.colorScheme.onSurface,
      ),
      child: Text(l10n.search_filters_top)
    )];

    final filterTranslations = {
      SearchFilter.track: l10n.search_filters_track,
      SearchFilter.artist: l10n.search_filters_artist,
      SearchFilter.album: l10n.search_filters_album,
      SearchFilter.book: l10n.search_filters_book,
      SearchFilter.playlist: l10n.search_filters_playlist,
      SearchFilter.podcast: l10n.search_filters_podcast,
    };

    for (var item in SearchFilter.values) {
      Color borderColor = Colors.transparent;
      if(filter == item) {
        borderColor = theme.colorScheme.primary;
      }

      items.add(
        OutlinedButton(
          onPressed: (){
            filter = item;
            isDefaultView = false;
            setState(() {});
          },
          // style: filter == item ? style : null,
          style: OutlinedButton.styleFrom(
            side: BorderSide(width: 2, color: borderColor),
            foregroundColor: theme.colorScheme.onSurface,
          ),
          child: Text(filterTranslations[item]!),
        )
      );
    }

    return Row(spacing: 8, children: items);
  }
}

