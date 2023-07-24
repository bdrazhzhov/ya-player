import 'album.dart';
import 'artist.dart';
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
    if(json['result']['best'] != null) best = BestSuggestion.fromJson(json['result']['best']);

    final suggestions = (json['result']['suggestions'] as List).map((i) => i as String).toList();

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

    switch(type) {
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
  final ResultsContainer<LikedArtist>? artists;
  final ResultsContainer<Album>? albums;
  final ResultsContainer<Track>? tracks;
  final ResultsContainer<Playlist>? playlists;
  final ResultsContainer<Podcast>? podcasts;
  final ResultsContainer<PodcastEpisode>? podcastEpisodes;

  SearchResult(this.artists, this.albums, this.tracks,
      this.playlists, this.podcasts, this.podcastEpisodes);

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final result = json['result'];

    ResultsContainer<LikedArtist>? artists;
    if(result['artists'] != null) {
      artists = ResultsContainer.fromJson(result['artists']);
      result['artists']['results'].forEach((a) => artists!.results.add(LikedArtist.fromJson(a)));
    }

    ResultsContainer<Album>? albums;
    if(result['albums'] != null) {
      albums = ResultsContainer.fromJson(result['albums']);
      result['albums']['results'].forEach((a) => albums!.results.add(Album.fromJson(a)));
    }

    ResultsContainer<Track>? tracks;
    if(result['tracks'] != null) {
      tracks = ResultsContainer.fromJson(result['tracks']);
      result['tracks']['results'].forEach((a) => tracks!.results.add(Track.fromJson(a, '')));
    }

    ResultsContainer<Playlist>? playlists;
    if(result['playlists'] != null) {
      playlists = ResultsContainer.fromJson(result['playlists']);
      result['playlists']['results'].forEach((a) => playlists!.results.add(Playlist.fromJson(a)));
    }

    ResultsContainer<Podcast>? podcasts;
    if(result['podcasts'] != null) {
      podcasts = ResultsContainer.fromJson(result['podcasts']);
      result['podcasts']['results'].forEach((a) => podcasts!.results.add(Podcast.fromJson(a)));
    }

    ResultsContainer<PodcastEpisode>? podcastEpisodes;
    if(result['podcast_episodes'] != null) {
      podcastEpisodes = ResultsContainer.fromJson(result['podcast_episodes']);
      result['podcast_episodes']['results'].forEach((a) => podcastEpisodes!.results.add(PodcastEpisode.fromJson(a)));
    }

    return SearchResult(artists, albums, tracks, playlists, podcasts, podcastEpisodes);
  }
}
