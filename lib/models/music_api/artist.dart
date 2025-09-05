import 'package:ya_player/models/music_api/station.dart';

import 'can_be_station.dart';
import 'context_id.dart';

class ArtistBase implements CanBeRadio, ContextId {
  final String id;
  final String name;

  ArtistBase(this.id, this.name);

  factory ArtistBase.fromJson(Map<String, dynamic> json) {
    return ArtistBase(json['id']?.toString() ?? '', json['name']);
  }

  @override
  StationId stationId() => StationId('artist', id);

  @override
  String get contextId => id;
}

class Artist extends ArtistBase {
  final ArtistCover? cover;
  final List<String> genres;
  final ArtistCounts? counts;
  final List<ArtistLink> links;
  final List<ArtistExtraAction> extraActions;

  Artist(super.id, super.name, this.cover, this.genres, this.counts, this.links, this.extraActions);

  factory Artist.fromJson(Map<String, dynamic> json) {
    List<String> genres = [];
    json['genres']?.forEach((genre) => genres.add(genre));

    List<ArtistLink> links = [];
    if (json['links'] != null) {
      json['links'].forEach((linkJson) => links.add(ArtistLink.fromJson(linkJson)));
    }

    ArtistCover? cover;
    if (json['cover'] != null) cover = ArtistCover.fromJson(json['cover']);

    List<ArtistExtraAction> extraActions = [];
    if (json['extraActions'] != null) {
      json['extraActions']
          .forEach((action) => extraActions.add(ArtistExtraAction.fromJson(action)));
    }

    final counts = json['counts'] != null ? ArtistCounts.fromJson(json['counts']) : null;

    return Artist(json['id'].toString(), json['name'], cover, genres, counts, links, extraActions);
  }
}

class ArtistCover {
  final String uri;
  final DerivedColors? derivedColors;

  ArtistCover({required this.uri, this.derivedColors});

  factory ArtistCover.fromJson(Map<String, dynamic> json) {
    DerivedColors? derivedColors;
    if (json['derivedColors'] != null) {
      derivedColors = DerivedColors.fromJson(json['derivedColors']);
    }

    return ArtistCover(uri: json['uri'], derivedColors: derivedColors);
  }
}

class DerivedColors {
  final String average;
  final String waveText;
  final String miniPlayer;
  final String accent;

  DerivedColors({
    required this.average,
    required this.waveText,
    required this.miniPlayer,
    required this.accent,
  });

  factory DerivedColors.fromJson(Map<String, dynamic> json) {
    return DerivedColors(
      average: json['average'],
      waveText: json['waveText'],
      miniPlayer: json['miniPlayer'],
      accent: json['accent'],
    );
  }
}

class ArtistCounts {
  final int tracks;
  final int directAlbums;
  final int alsoAlbums;
  final int alsoTracks;

  ArtistCounts(this.tracks, this.directAlbums, this.alsoAlbums, this.alsoTracks);

  factory ArtistCounts.fromJson(Map<String, dynamic> json) {
    return ArtistCounts(
        json['tracks'], json['directAlbums'], json['alsoAlbums'], json['alsoTracks']);
  }
}

class ArtistLink {
  final String title;
  final String href;
  final String type;
  final String? socialNetwork;

  ArtistLink(this.title, this.href, this.type, this.socialNetwork);

  factory ArtistLink.fromJson(Map<String, dynamic> json) {
    return ArtistLink(json['title'], json['href'], json['type'], json['socialNetwork']);
  }
}

class ArtistExtraAction {
  final String type;
  final String title;
  final String color;
  final String url;

  ArtistExtraAction({
    required this.type,
    required this.title,
    required this.color,
    required this.url,
  });

  factory ArtistExtraAction.fromJson(Map<String, dynamic> json) {
    return ArtistExtraAction(
      type: json['type'],
      title: json['title'],
      color: json['color'],
      url: json['url'],
    );
  }
}
