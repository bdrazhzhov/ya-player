import 'artist.dart';

class Album {
  final int id;
  final String title;
  final int? year;
  final DateTime? releaseDate;
  final String coverUri;
  final String ogImage;
  final String genre;
  final int tracksCount;
  final List<ArtistBase> artists;

  Album(this.id, this.title, this.year, this.releaseDate, this.coverUri,
      this.ogImage, this.genre, this.tracksCount, this.artists);
  
  factory Album.fromJson(Map<String, dynamic> json) {
    List<ArtistBase> artists = [];
    json['artists'].forEach((item) {
      artists.add(ArtistBase.fromJson(item));
    });

    DateTime? releaseDate;
    if(json['releaseDate'] != null) {
      releaseDate = DateTime.parse(json['releaseDate']);
    }

    return Album(json['id'], json['title'], json['year'], releaseDate,
        json['coverUri'], json['ogImage'], json['genre'] ?? '', json['trackCount'], artists);
  }
}