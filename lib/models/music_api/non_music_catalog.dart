import 'package:flutter/cupertino.dart';

import 'podcast.dart';

class NonMusicCatalog {
  final String title;
  final List<Block> blocks;

  NonMusicCatalog({required this.title, required this.blocks});

  factory NonMusicCatalog.fromJson(Map<String, dynamic> json) {
    List<Block> blocks = [];
    for(Map<String, dynamic> blockJson in json['blocks']) {
      if(blockJson['viewAllUrl'] == null) {
        debugPrint("Block '${blockJson['id']}' skipped");
        continue;
      }
      //TODO: learn how to deal with charts
      if(blockJson['typeForFrom'] != 'chart') {
        blocks.add(Block.fromJson(blockJson));
      }
      else {
        debugPrint('Skipped block: ${blockJson['id']} ${blockJson['title']} ${blockJson['description']}');
      }
    }

    return NonMusicCatalog(title: json['title'], blocks: blocks);
  }
}

class Block {
  final String id;
  final String? title;
  final String? description;
  final String type;
  final String typeForFrom;
  final String? viewAllUrl;
  final String? viewAllUrlScheme;
  final List<Podcast> entities;

  Block({required this.id, this.title, this.description,
    required this.type, required this.typeForFrom, this.viewAllUrl,
    this.viewAllUrlScheme, required this.entities});

  factory Block.fromJson(Map<String, dynamic> json) {
    List<Podcast> entities = [];
    for(Map<String, dynamic> entityJson in json['entities']) {
      if(entityJson['type'] == 'playlist') {
        debugPrint('Skipped entity: ${entityJson['data']['title']}');
        continue;
      }

      entities.add(Podcast.fromJson(entityJson['data']));
    }


    return Block(id: json['id'], title: json['title'], description: json['description'],
        type: json['type'], typeForFrom: json['typeForFrom'], viewAllUrl: json['viewAllUrl'],
        viewAllUrlScheme: json['viewAllUrlScheme'], entities: entities);
  }
}
