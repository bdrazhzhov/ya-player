import 'package:flutter/foundation.dart';

import 'playlist.dart';

class Block {
  final String id;
  final String? title;
  final String? description;
  final String type;
  final String typeForFrom;
  final String? viewAllUrl;
  final String? viewAllUrlScheme;
  final List<Object> entities;

  Block({required this.id, this.title, this.description,
    required this.type, required this.typeForFrom, this.viewAllUrl,
    this.viewAllUrlScheme, required this.entities});

  factory Block.fromJson(Map<String, dynamic> json) {
    List<Object> entities = [];
    final String type = json['type'];

    switch(type) {
      case 'personal-playlists':
        json['entities'].forEach(
          (entity) => entities.add(Playlist.fromJson(entity['data']['data']))
        );
      default:
        debugPrint('Unknown block type: "$type"');
    }

    return Block(id: json['id'], title: json['title'], description: json['description'],
        type: type, typeForFrom: json['typeForFrom'], viewAllUrl: json['viewAllUrl'],
        viewAllUrlScheme: json['viewAllUrlScheme'], entities: entities);
  }
}
