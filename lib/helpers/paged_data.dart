class PagedData<T> {
  final int page;
  final int perPage;
  final int total;
  final List<T> items;

  PagedData({
    required this.page,
    required this.perPage,
    required this.total,
    required this.items
  });

  factory PagedData.fromJson(Map<String, dynamic> json, List<T> items) {
    return PagedData(
      page: json['page'],
      perPage: json['perPage'],
      total: json['total'],
      items: items
    );
  }
}
