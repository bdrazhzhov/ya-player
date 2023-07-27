import 'package:flutter/foundation.dart';

import 'artist.dart';
import 'podcast.dart';
import 'promotion.dart';
import 'album.dart';
import 'playlist.dart';
import 'track.dart';

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
      case 'play-contexts':
        json['entities'].forEach((entity) {
          final object = _createPlayContext(entity);
          if(object == null) return;
          entities.add(object);
        });
      case 'promotions':
        json['entities'].forEach(
          (entity) => entities.add(Promotion.fromJson(entity['data']))
        );
      case 'podcasts':
        json['entities'].forEach((entity) => entities.add(Podcast.fromJson(entity)));
      case 'new-releases':
        json['entities'].forEach((entity) => entities.add(Album.fromJson(entity['data'])));
      case 'new-playlists':
        json['entities'].forEach((entity) => entities.add(Playlist.fromJson(entity['data'])));
      case 'chart':
        json['entities'].forEach((entity) => entities.add(Track.fromJson(entity['data']['track'], '')));
      default:
        debugPrint('Unknown block type: "$type"');
    }

    return Block(id: json['id'], title: json['title'], description: json['description'],
        type: type, typeForFrom: json['typeForFrom'], viewAllUrl: json['viewAllUrl'],
        viewAllUrlScheme: json['viewAllUrlScheme'], entities: entities);
  }

  static Object? _createPlayContext(entity) {
    final String context = entity['data']['context'];
    final payload = entity['data']['payload'];
    if(payload == null) return null;

    switch(context) {
      case 'album':
        return Album.fromJson(payload);
      case 'playlist':
        return Playlist.fromJson(payload);
      case 'artist':
        return LikedArtist.fromJson(payload);
      default:
        debugPrint('Unknown play context: $context');
    }

    return null;
  }
}
