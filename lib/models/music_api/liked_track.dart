class LikedTrack {
  final String id;
  final String albumId;

  LikedTrack(this.id, this.albumId);

  factory LikedTrack.fromJson(Map<String, dynamic> json) {
    return LikedTrack(json['id'], json['albumId']);
  }
}