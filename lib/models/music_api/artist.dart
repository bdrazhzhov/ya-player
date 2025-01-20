class ArtistBase {
  final int id;
  final String name;

  ArtistBase(this.id, this.name);

  factory ArtistBase.fromJson(Map<String, dynamic> json) {
    return ArtistBase(json['id'], json['name']);
  }
}

class Artist extends ArtistBase {
  final ArtistCover? cover;
  final List<String> genres;
  final ArtistCounts counts;
  final List<ArtistLink> links;
  final List<ArtistExtraAction> extraActions;

  Artist(super.id, super.name, this.cover, this.genres, this.counts, this.links, this.extraActions);

  factory Artist.fromJson(Map<String, dynamic> json) {
    List<String> genres = [];
    json['genres'].forEach((genre) => genres.add(genre));

    List<ArtistLink> links = [];
    if(json['links'] != null) {
      json['links'].forEach((linkJson) => links.add(ArtistLink.fromJson(linkJson)));
    }

    ArtistCover? cover;
    if(json['cover'] != null) cover = ArtistCover.fromJson(json['cover']);

    List<ArtistExtraAction> extraActions = [];
    if(json['extraActions'] != null) {
      json['extraActions'].forEach((action) => extraActions.add(ArtistExtraAction.fromJson(action)));
    }

    return Artist(
      json['id'] is String ? int.parse(json['id']) : json['id'],
      json['name'], cover, genres,
      ArtistCounts.fromJson(json['counts']), links, extraActions
    );
  }
}

class ArtistCover {
  final String type;
  final String prefix;
  final String uri;

  ArtistCover(this.type, this.prefix, this.uri);

  factory ArtistCover.fromJson(Map<String, dynamic> json) {
    return ArtistCover(json['type'], json['prefix'], json['uri']);
  }
}

class ArtistCounts {
  final int tracks;
  final int directAlbums;
  final int alsoAlbums;
  final int alsoTracks;

  ArtistCounts(this.tracks, this.directAlbums, this.alsoAlbums, this.alsoTracks);

  factory ArtistCounts.fromJson(Map<String, dynamic> json) {
    return ArtistCounts(json['tracks'], json['directAlbums'],
        json['alsoAlbums'], json['alsoTracks']);
  }
}

class ArtistLink {
  final String title;
  final String href;
  final String type;
  final String? socialNetwork;

  ArtistLink(this.title, this.href, this.type, this.socialNetwork);

  factory ArtistLink.fromJson(Map<String, dynamic> json) {
    return ArtistLink(json['title'], json['href'],
        json['type'], json['socialNetwork']);
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
