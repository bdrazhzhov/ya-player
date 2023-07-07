import 'dart:convert';

import 'station.dart';

class Queue {
  final QueueContext context;
  final int? currentIndex;
  final String from;
  final bool isInteractive;
  final List<QueueTrack> tracks;

  Queue(this.context, this.currentIndex, this.from, this.isInteractive, this.tracks);

  Map<String, String> toJons() => {
    'context': jsonEncode(context.toJons()),
    'currentIndex': jsonEncode(currentIndex),
    'from': from,
    'isInteractive': jsonEncode(isInteractive),
    'tracks': jsonEncode(tracks)
  };
}

class QueueContext {
  final String description;
  final StationId id;
  final String type = 'radio';

  QueueContext(this.description, this.id);

  Map<String, String> toJons() => {
    'description': description,
    'id': jsonEncode(id.toJson()),
    'type': type
  };
}

class QueueTrack {
  final String trackId;
  final String albumId;
  final String from;

  QueueTrack(this.trackId, this.albumId, this.from);

  Map<String, String> toJons() => {
    'trackId': trackId,
    'albumId': albumId,
    'from': from
  };
}
