import 'package:flutter/foundation.dart';

import 'artist.dart';
import 'mix_link.dart';
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
        json['entities'].forEach((entity) => _createPlayContext(entity, entities));
      case 'promotions':
        json['entities'].forEach(
          (entity) => entities.add(Promotion.fromJson(entity['data'])),
        );
      case 'podcasts':
        json['entities'].forEach((entity) => entities.add(Podcast.fromJson(entity)));
      case 'new-releases':
        json['entities'].forEach((entity) => entities.add(Album.fromJson(entity['data'])));
      case 'new-playlists':
        json['entities'].forEach((entity) => entities.add(Playlist.fromJson(entity['data'])));
      case 'chart':
        json['entities'].forEach((entity) => entities.add(Track.fromJson(entity['data']['track'], '')));
      case 'mixes':
        json['entities'].forEach((entity) => entities.add(MixLink.fromJson(entity['data'])));
      case 'editorial-playlists':
        json['entities'].forEach((entity) => _createPodcastEntity(entity, entities));
      case 'album-chart':
        json['entities'].forEach((entity) => entities.add(Podcast.fromJson(entity['data']['album'])));
      case 'playlist-with-tracks':
        json['entities'].forEach((entity) => entities.add(Playlist.fromJson(entity['data'])));
      case 'recently-played':
        json['entities'].forEach((entity) => _createRecentlyPlayed(entity, entities));
      default:
        debugPrint('Unknown block type: "$type"');
    }

    return Block(id: json['id'], title: json['title'], description: json['description'],
        type: type, typeForFrom: json['typeForFrom'], viewAllUrl: json['viewAllUrl'],
        viewAllUrlScheme: json['viewAllUrlScheme'], entities: entities);
  }

  static void _createRecentlyPlayed(entity, List<Object> entities) {
    switch(entity['type']) {
      case 'album':
        entities.add(Album.fromJson(entity['data']));
      case 'playlist':
        entities.add(Playlist.fromJson(entity['data']));
      default:
        debugPrint('Unknown recent-played type: "${entity['type']}"');
    }
  }

  static void _createPodcastEntity(Map<String, dynamic> entityJson, List<Object> entities) {
    if(entityJson['type'] == 'playlist') {
      entities.add(Playlist.fromJson(entityJson['data']));
    } else {
      entities.add(Podcast.fromJson(entityJson['data']));
    }
  }

  static void _createPlayContext(entity, List<Object> entities) {
    final String context = entity['data']['context'];
    final payload = entity['data']['payload'];
    if(payload == null) return;

    switch(context) {
      case 'album':
        entities.add(Album.fromJson(payload));
      case 'playlist':
        entities.add(Playlist.fromJson(payload));
      case 'artist':
        entities.add(Artist.fromJson(payload));
      default:
        debugPrint('Unknown play context: $context');
    }
  }
}
