import 'package:ya_player/models/music_api_types.dart';

class Tree {
  final String title;
  final String navigationId;
  final List<Leaf> leaves;

  Tree({
    required this.title,
    required this.navigationId,
    required this.leaves,
  });

  factory Tree.fromJson(Map<String, dynamic> json) {
    List<Leaf> leaves = [];
    json['leaves']?.forEach((leafJson) => leaves.add(Leaf.fromJson(leafJson)));

    return Tree(
      title: json['title'],
      navigationId: json['navigationId'],
      leaves: leaves,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'navigationId': navigationId,
    'leaves': leaves.map((leaf) => leaf.toJson()).toList(),
  };
}

class Leaf {
  final String tag;
  final String title;
  final List<Leaf> leaves;

  Leaf({
    required this.tag,
    required this.title,
    required this.leaves,
  });

  factory Leaf.fromJson(Map<String, dynamic> json) {
    List<Leaf> leaves = [];
    json['leaves']?.forEach((leafJson) => leaves.add(Leaf.fromJson(leafJson)));

    return Leaf(
      tag: json['tag'],
      title: json['title'],
      leaves: leaves
    );
  }

  Map<String, dynamic> toJson() => {
    'tag': tag,
    'title': title,
    'leaves': leaves.map((leaf) => leaf.toJson()).toList(),
  };
}

class MetaTags {
  final String id;
  final String? coverUri;
  final String color;
  final MetaTagTitle title;
  final bool liked;
  final String stationId;
  final String customWaveAnimationUrl;
  final List<Track> tracks;
  final List<Artist> artists;
  final List<dynamic> composers;
  final List<Album> albums;
  final List<dynamic> promotions;
  final List<dynamic> features;
  final List<Playlist> playlists;
  final List<SortByValue> tracksSortByValues;
  final List<SortByValue> albumsSortByValues;
  final List<SortByValue> playlistsSortByValues;

  MetaTags({
    required this.id,
    this.coverUri,
    required this.color,
    required this.title,
    required this.liked,
    required this.stationId,
    required this.customWaveAnimationUrl,
    required this.tracks,
    required this.artists,
    required this.composers,
    required this.albums,
    required this.promotions,
    required this.features,
    required this.playlists,
    required this.tracksSortByValues,
    required this.albumsSortByValues,
    required this.playlistsSortByValues,
  });

  factory MetaTags.fromJson(Map<String, dynamic> json) {
    List<Track> tracks = [];
    json['tracks'].forEach((track) => tracks.add(Track.fromJson(track, '')));

    List<Artist> artists = [];
    json['artists'].forEach((artist) => artists.add(Artist.fromJson(artist)));

    List<Album> albums = [];
    json['albums'].forEach((album) => albums.add(Album.fromJson(album)));

    List<Playlist> playlists = [];
    json['playlists'].forEach((playlist) => playlists.add(Playlist.fromJson(playlist)));
    
    return MetaTags(
      id: json['id'],
      coverUri: json['coverUri'],
      color: json['color'],
      title: MetaTagTitle.fromJson(json['title']),
      liked: json['liked'],
      stationId: json['stationId'],
      customWaveAnimationUrl: json['customWaveAnimationUrl'],
      tracks: tracks,
      artists: artists,
      composers: json['composers'],
      albums: albums,
      promotions: json['promotions'],
      features: json['features'],
      playlists: playlists,
      tracksSortByValues: json['tracksSortByValues']
          .map((e) => SortByValue.fromJson(e))
          .toList(),
      albumsSortByValues: json['albumsSortByValues']
          .map((e) => SortByValue.fromJson(e))
          .toList(),
      playlistsSortByValues: json['playlistsSortByValues']
          .map((e) => SortByValue.fromJson(e))
          .toList(),
    );
  }
}

class MetaTagTitle {
  final String title;
  final String fullTitle;

  MetaTagTitle({
    required this.title,
    required this.fullTitle,
  });

  factory MetaTagTitle.fromJson(Map<String, dynamic> json) {
    return MetaTagTitle(
      title: json['title'],
      fullTitle: json['fullTitle'],
    );
  }
}

class SortByValue {
  final String value;
  final String title;
  final bool active;

  SortByValue({
    required this.value,
    required this.title,
    required this.active,
  });

  factory SortByValue.fromJson(Map<String, dynamic> json) {
    return SortByValue(
      value: json['value'],
      title: json['title'],
      active: json['active'],
    );
  }
}
