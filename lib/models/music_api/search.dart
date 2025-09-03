import 'package:flutter/foundation.dart';

import 'album.dart';
import 'artist.dart';
import 'paged_data.dart';
import 'playlist.dart';
import 'podcast.dart';
import 'podcast_episode.dart';
import 'track.dart';

class SearchSuggestions {
  final List<String> entries;
  final BestSuggestion? best;

  SearchSuggestions(this.entries, this.best);

  factory SearchSuggestions.fromJson(Map<String, dynamic> json) {
    BestSuggestion? best;
    if (json['best'] != null) best = BestSuggestion.fromJson(json['best']);

    final suggestions = (json['suggestions'] as List).map((i) => i as String).toList();

    return SearchSuggestions(suggestions, best);
  }
}

class BestSuggestion {
  final String type;
  final String title;
  final String text;
  final String imageUrl;

  BestSuggestion(this.type, this.text, this.title, this.imageUrl);

  factory BestSuggestion.fromJson(Map<String, dynamic> json) {
    final String type = json['type'];
    final resultJson = json['result'];
    String title;
    String imageUrl;

    switch (type) {
      case 'artist':
        title = resultJson['name'];
        imageUrl = resultJson['ogImage'];
      case 'album':
        title = resultJson['title'];
        imageUrl = resultJson['ogImage'];
      default:
        throw 'Unknown search best suggestion type';
    }

    return BestSuggestion(type, json['text'], title, imageUrl);
  }
}

class ResultsContainer<T extends Object> {
  final int total;
  final int perPage;
  final int order;
  final List<T> results = [];

  ResultsContainer(this.total, this.perPage, this.order);

  factory ResultsContainer.fromJson(Map<String, dynamic> json) {
    return ResultsContainer(json['total'], json['perPage'], json['order']);
  }
}

class SearchResult {
  final ResultsContainer<Artist>? artists;
  final ResultsContainer<Album>? albums;
  final ResultsContainer<Track>? tracks;
  final ResultsContainer<Playlist>? playlists;
  final ResultsContainer<Podcast>? podcasts;
  final ResultsContainer<PodcastEpisode>? podcastEpisodes;

  SearchResult(
      this.artists, this.albums, this.tracks, this.playlists, this.podcasts, this.podcastEpisodes);

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    ResultsContainer<Artist>? artists;
    if (json['artists'] != null) {
      artists = ResultsContainer.fromJson(json['artists']);
      json['artists']['results'].forEach((a) => artists!.results.add(Artist.fromJson(a)));
    }

    ResultsContainer<Album>? albums;
    if (json['albums'] != null) {
      albums = ResultsContainer.fromJson(json['albums']);
      json['albums']['results'].forEach((a) => albums!.results.add(Album.fromJson(a)));
    }

    ResultsContainer<Track>? tracks;
    if (json['tracks'] != null) {
      tracks = ResultsContainer.fromJson(json['tracks']);
      json['tracks']['results'].forEach((a) => tracks!.results.add(Track.fromJson(a, '')));
    }

    ResultsContainer<Playlist>? playlists;
    if (json['playlists'] != null) {
      playlists = ResultsContainer.fromJson(json['playlists']);
      json['playlists']['results'].forEach((a) => playlists!.results.add(Playlist.fromJson(a)));
    }

    ResultsContainer<Podcast>? podcasts;
    if (json['podcasts'] != null) {
      podcasts = ResultsContainer.fromJson(json['podcasts']);
      json['podcasts']['results'].forEach((a) => podcasts!.results.add(Podcast.fromJson(a)));
    }

    ResultsContainer<PodcastEpisode>? podcastEpisodes;
    if (json['podcast_episodes'] != null) {
      podcastEpisodes = ResultsContainer.fromJson(json['podcast_episodes']);
      json['podcast_episodes']['results']
          .forEach((a) => podcastEpisodes!.results.add(PodcastEpisode.fromJson(a)));
    }

    return SearchResult(artists, albums, tracks, playlists, podcasts, podcastEpisodes);
  }
}

enum SearchFilter { artist, track, album, playlist, podcast, book }

class SearchResultMixed extends PagedData<Object> {
  final SearchFilter? filter;

  SearchResultMixed(
      {required super.page,
      required super.perPage,
      required super.total,
      required super.items,
      this.filter});
}

Object? createSearchResultEntry(item) {
  Object? result;

  switch (item['type']) {
    case 'album':
      result = Album.fromJson(item['album']);
    case 'track':
      result = Track.fromJson(item['track'], '');
    case 'artist':
      result = Artist.fromJson(item['artist']);
    case 'playlist':
      result = Playlist.fromJson(item['playlist']);
    case 'podcast':
      result = Podcast.fromJson(item['podcast']);
    case 'podcast_episode':
      result = PodcastEpisode.fromJson(item['podcast_episode']);
    default:
      debugPrint('Unknown search result item type: ${item['type']}');
  }

  return result;
}
