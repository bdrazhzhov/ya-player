class ArtistBase {
  final int id;
  final String name;

  ArtistBase(this.id, this.name);

  factory ArtistBase.fromJson(Map<String, dynamic> json) {
    return ArtistBase(json['id'], json['name']);
  }
}

class LikedArtist extends ArtistBase {
  final ArtistCover cover;
  final List<String> genres;
  final ArtistCounts counts;
  final List<ArtistLink> links;

  LikedArtist(super.id, super.name, this.cover, this.genres, this.counts, this.links);

  factory LikedArtist.fromJson(Map<String, dynamic> json) {
    List<String> genres = [];
    json['genres'].forEach((genre) => genres.add(genre));

    List<ArtistLink> links = [];
    if(json['links'] != null) {
      json['links'].forEach((linkJson) => links.add(ArtistLink.fromJson(linkJson)));
    }

    return LikedArtist(
      json['id'] is String ? int.parse(json['id']) : json['id'],
      json['name'], ArtistCover.fromJson(json['cover']), genres,
      ArtistCounts.fromJson(json['counts']), links
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
