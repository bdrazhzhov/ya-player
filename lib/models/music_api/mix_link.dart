class MixLink {
  final String title;
  final String url;
  final String image;

  MixLink({required this.title, required this.url, required this.image});

  factory MixLink.fromJson(Map<String, dynamic> json) {
    return MixLink(title: json['title'], url: json['url'], image: json['backgroundImageUri']);
  }
}
