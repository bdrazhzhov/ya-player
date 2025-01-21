class Tree {
  final String title;
  final String navigationId;
  final List<Leaf> leaves;

  Tree({
    required this.title,
    required this.navigationId,
    required this.leaves,
  });

  factory Tree.fromJson(Map<String, dynamic> json) {
    List<Leaf> leaves = [];
    json['leaves']?.forEach((leafJson) => leaves.add(Leaf.fromJson(leafJson)));

    return Tree(
      title: json['title'],
      navigationId: json['navigationId'],
      leaves: leaves,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'navigationId': navigationId,
    'leaves': leaves.map((leaf) => leaf.toJson()).toList(),
  };
}

class Leaf {
  final String tag;
  final String title;
  final List<Leaf> leaves;

  Leaf({
    required this.tag,
    required this.title,
    required this.leaves,
  });

  factory Leaf.fromJson(Map<String, dynamic> json) {
    List<Leaf> leaves = [];
    json['leaves']?.forEach((leafJson) => leaves.add(Leaf.fromJson(leafJson)));

    return Leaf(
      tag: json['tag'],
      title: json['title'],
      leaves: leaves
    );
  }

  Map<String, dynamic> toJson() => {
    'tag': tag,
    'title': title,
    'leaves': leaves.map((leaf) => leaf.toJson()).toList(),
  };
}
