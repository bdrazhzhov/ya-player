import '/helpers/date_extensions.dart';

class RadioFeedback {
  final RadioEvent event;
  final String batchId;

  RadioFeedback({
    required this.event,
    required this.batchId,
  });

  Map<String, dynamic> toJson() {
    return {
      'event': event.toJson(),
      'batchId': batchId,
    };
  }
}

enum RadioEventType {
  radioStarted, trackStarted, trackFinished, skip, like, unlike;
  
  factory RadioEventType.fromString(String stringValue) {
    for (RadioEventType value in values) {
      if (value.name == stringValue) {
        return value;
      }
    }

    throw ArgumentError('Unknown event type: $stringValue');
  }
}

class RadioEvent {
  final DateTime timestamp;
  final RadioEventType type;
  final String from;
  String? trackId;
  Duration? totalPlayed;

  RadioEvent({
    required this.type,
    required this.from,
    this.trackId,
    this.totalPlayed,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'timestamp': timestamp.toUtcString(),
      'type': type.name,
      'from': from,
    };

    if(trackId != null) {
      json['trackId'] = trackId!;
    }

    if(totalPlayed != null) {
      json['totalPlayedSeconds'] = totalPlayed!.inMilliseconds / 1000.0;
    }

    return json;
  }
}
