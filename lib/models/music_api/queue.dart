import 'package:equatable/equatable.dart';

class Queue extends Equatable {
  final String? id;
  final QueueContext context;
  final int? currentIndex;
  final String? from;
  final bool? isInteractive;
  final Iterable<QueueTrack> tracks;

  const Queue({this.id, required this.context,
    this.currentIndex, this.from, this.isInteractive,
    required this.tracks});

  @override
  List<Object?> get props => [id];

  factory Queue.fromJson(Map<String, dynamic> json) {
    List<QueueTrack> tracks = [];

    json['tracks'].forEach((t) => tracks.add(QueueTrack.fromJson(t)));

    return Queue(
      id: json['id'],
      context: QueueContext.fromJson(json['context']),
      tracks: tracks,
      currentIndex: json['currentIndex'],
      from: json['from'] ?? tracks.firstOrNull?.from
    );
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'context': context.toMap(),
      'currentIndex': currentIndex,
      'from': from,
      'tracks': tracks
    };

    if(isInteractive != null) data['isInteractive'] = (isInteractive! ? 'True' : 'False');

    return data;
  }
}

class QueueContext extends Equatable {
  final String? description;
  final String? id;
  final String type;

  const QueueContext({required this.description, required this.id, required this.type});

  factory QueueContext.fromJson(Map<String, dynamic> json) {
    return QueueContext(
      description: json['description'],
      id: json['id'].toString(),
      type: json['type']
    );
  }

  Map<String, String> toMap() => {
    'description': description ?? '',
    'id': id ?? '',
    'type': type
  };

  @override
  List<Object?> get props => [type, id];
}

class QueueTrack {
  final String trackId;
  final String albumId;
  final String from;

  QueueTrack(this.trackId, this.albumId, this.from);

  factory QueueTrack.fromJson(Map<String, dynamic> json) {
    return QueueTrack(json['trackId'], json['albumId'], json['from']);
  }

  Map<String, String> toJson() => {
    'trackId': trackId,
    'albumId': albumId,
    'from': from
  };
}
