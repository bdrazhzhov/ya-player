class Podcast {
  final int id;
  final String title;
  final String ogImage;
  final int trackCount;
  final int? likesCount;
  final bool? isAvailable;

  Podcast(this.id, this.title, this.ogImage, this.trackCount,
      this.likesCount, this.isAvailable);

  factory Podcast.fromJson(Map<String, dynamic> json) {
    return Podcast(json['id'], json['title'], json['ogImage'],
        json['trackCount'], json['likesCount'], json['isAvailable']);
  }
}