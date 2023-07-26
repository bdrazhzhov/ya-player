import 'package:flutter/foundation.dart';

class Block {
  final String id;
  final String? title;
  final String? description;
  final String type;
  final String typeForFrom;
  final String? viewAllUrl;
  final String? viewAllUrlScheme;
  final List<BlockEntity> entities;

  Block({required this.id, this.title, this.description,
    required this.type, required this.typeForFrom, this.viewAllUrl,
    this.viewAllUrlScheme, required this.entities});

  factory Block.fromJson(Map<String, dynamic> json) {
    List<BlockEntity> entities = [];
    final String type = json['type'];

    switch(type) {
      case 'personal-playlists':
        json['entities'].forEach(
          (entity) => entities.add(BlockPlaylist.fromJson(entity['data']['data']))
        );
      default:
        debugPrint('Unknown block type: "$type"');
    }

    return Block(id: json['id'], title: json['title'], description: json['description'],
        type: type, typeForFrom: json['typeForFrom'], viewAllUrl: json['viewAllUrl'],
        viewAllUrlScheme: json['viewAllUrlScheme'], entities: entities);
  }
}

class BlockEntity {}

class BlockPlaylist extends BlockEntity {
  final int kind;
  final String title;
  final int uid;
  final String description;
  final String ownerName;
  final Duration duration;
  final int trackCount;
  final String image;

  BlockPlaylist({
    required this.kind,
    required this.title,
    required this.uid,
    required this.description,
    required this.ownerName,
    required this.duration,
    required this.trackCount,
    required this.image
  });

  factory BlockPlaylist.fromJson(Map<String, dynamic> json) {
    String image = json['coverWithoutText'] != null ? json['coverWithoutText']['uri'] : json['ogImage'];

    return BlockPlaylist(kind: json['kind'], title: json['title'], uid: json['uid'],
        description: json['description'], ownerName: json['owner']['name'],
        duration: Duration(milliseconds: json['durationMs']),
        trackCount: json['trackCount'], image: image);
  }
}
