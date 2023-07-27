import 'package:flutter/material.dart';
import 'package:ya_player/controls/album_card.dart';
import 'package:ya_player/controls/playlist_card.dart';
import 'package:ya_player/controls/podcast_card.dart';
import 'package:ya_player/controls/track_list.dart';

import '../app_state.dart';
import '../controls/artist_card.dart';
import '../controls/podcast_episodes_list.dart';
import '../services/service_locator.dart';

class SearchResultsPage extends StatelessWidget {
  final _appState = getIt<AppState>();
  static const double _cardSize = 160;

  SearchResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              BackButton(),
              Text('Search results'),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(right: 32),
                child: ValueListenableBuilder(
                  valueListenable: _appState.searchResultNotifier,
                  builder: (_, searchResult, __) {
                    if(searchResult == null) return const SizedBox.shrink();

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (searchResult.artists != null && searchResult.artists!.results.isNotEmpty)
                          ..._buildSection(
                              sectionName: 'Artists',
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: searchResult.artists!.results.take(5).map((artist) => ArtistCard(artist, _cardSize)).toList(),
                              )
                          ),
                        if(searchResult.albums != null && searchResult.albums!.results.isNotEmpty)
                          ..._buildSection(
                              sectionName: 'Albums',
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: searchResult.albums!.results.take(5).map((album) => AlbumCard(album, _cardSize)).toList(),
                              )
                          ),
                        if(searchResult.tracks != null && searchResult.tracks!.results.isNotEmpty)
                          ..._buildSection(
                            sectionName: 'Tracks',
                            child: TrackList(searchResult.tracks!.results.take(6).toList(), showAlbum: true, showHeader: false)
                          ),
                        if(searchResult.podcasts != null && searchResult.podcasts!.results.isNotEmpty)
                          ..._buildSection(
                              sectionName: 'Podcasts',
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: searchResult.podcasts!.results.take(5).map((podcast) => PodcastCard(podcast, _cardSize)).toList(),
                              )
                          ),
                        if(searchResult.podcastEpisodes != null && searchResult.podcastEpisodes!.results.isNotEmpty)
                          ..._buildSection(
                              sectionName: 'Podcast episodes',
                              child: PodcastEpisodesList(searchResult.podcastEpisodes!.results.take(6).toList()),
                          ),
                        if(searchResult.playlists != null && searchResult.playlists!.results.isNotEmpty)
                          ..._buildSection(
                              sectionName: 'Playlists',
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: searchResult.playlists!.results.take(5).map((playlist) => PlaylistCard(playlist, width: _cardSize)).toList(),
                              )
                          ),
                      ],
                    );
                  }
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

List<Widget> _buildSection({required String sectionName, required Widget child}) {
  return [
    Padding(
      padding: const EdgeInsets.only(top: 32, bottom: 12),
      child: Text(
        sectionName,
        style: const TextStyle(fontSize: 20),
      ),
    ),
    child
  ];
}

