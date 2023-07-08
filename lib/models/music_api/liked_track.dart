class LikedTrack {
  final int id;
  final int albumId;

  LikedTrack(this.id, this.albumId);

  factory LikedTrack.fromJson(Map<String, dynamic> json) {
    return LikedTrack(
      int.parse(json['id']),
      int.parse(json['albumId'])
    );
  }
}