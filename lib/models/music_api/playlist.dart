class Playlist {
  final String title;
  final int tracksCount;
  final String ogImage;

  Playlist(this.title, this.tracksCount, this.ogImage);

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(json['title'], json['trackCount'], json['ogImage']);
  }
}
