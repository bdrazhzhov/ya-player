class Artist {
  final int id;
  final String name;

  Artist(this.id, this.name);

  factory Artist.fromJson(Map<String, dynamic> json) {
    return Artist(json['id'], json['name']);
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
