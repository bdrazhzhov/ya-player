class Queue {
  final QueueContext context;
  final int? currentIndex;
  final String? from;
  final bool? isInteractive;
  final List<QueueTrack> tracks;

  Queue({required this.context, this.currentIndex,this.from,
    this.isInteractive, required this.tracks});

  Map<String, dynamic> toMap() {
    Map<String, dynamic> data = {
      'context': context.toMap(),
      'currentIndex': currentIndex,
      'from': from,
      'tracks': tracks
    };

    if(isInteractive != null) data['isInteractive'] = isInteractive! ? 'True' : 'False';

    return data;
  }
}

class QueueContext {
  final String description;
  final String id;
  final String type;

  QueueContext({required this.description, required this.id, required this.type});

  Map<String, String> toMap() => {
    'description': description,
    'id': id,
    'type': type
  };
}

class QueueTrack {
  final String trackId;
  final String albumId;
  final String from;

  QueueTrack(this.trackId, this.albumId, this.from);

  Map<String, String> toJson() => {
    'trackId': trackId,
    'albumId': albumId,
    'from': from
  };
}
