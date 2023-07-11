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
  final String ogImage;
  List<String> genres;
  ArtistCounts counts;

  LikedArtist(super.id, super.name, this.cover,
      this.ogImage, this.genres, this.counts);

  factory LikedArtist.fromJson(Map<String, dynamic> json) {
    List<String> genres = [];
    json['genres'].forEach((genre) => genres.add(genre));

    return LikedArtist(json['id'] is String ? int.parse(json['id']) : json['id'],
        json['name'], ArtistCover.fromJson(json['cover']), json['ogImage'],
        genres, ArtistCounts.fromJson(json['counts']));
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
