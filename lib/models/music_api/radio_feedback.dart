import 'package:intl/intl.dart';

class StationFeedback {
  final StationEvent event;
  final String batchId;

  StationFeedback({
    required this.event,
    required this.batchId,
  });

  factory StationFeedback.fromJson(Map<String, dynamic> json) {
    return StationFeedback(
      event: StationEvent.fromJson(json['event']),
      batchId: json['batchId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'event': event.toJson(),
      'batchId': batchId,
    };
  }
}

enum StationEventType {
  radioStarted, trackStarted, trackFinished, skip, like, unlike;
  
  factory StationEventType.fromString(String stringValue) {
    for (StationEventType value in values) {
      if (value.name == stringValue) {
        return value;
      }
    }

    throw ArgumentError('Unknown event type: $stringValue');
  }
}

class StationEvent {
  final DateTime timestamp;
  final StationEventType type;
  final String from;
  final String trackId;
  final double totalPlayedSeconds;

  StationEvent({
    required this.timestamp,
    required this.type,
    required this.from,
    required this.trackId,
    required this.totalPlayedSeconds,
  });

  factory StationEvent.fromJson(Map<String, dynamic> json) {
    return StationEvent(
      timestamp: DateTime.parse(json['timestamp']),
      type: StationEventType.fromString(json['type']),
      from: json['from'],
      trackId: json['trackId'],
      totalPlayedSeconds: (json['totalPlayedSeconds'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': '${DateFormat('y-MM-ddTHH:mm:ss.S').format(timestamp.toUtc())}Z',
      'type': type.name,
      'from': from,
      'trackId': trackId,
      'totalPlayedSeconds': totalPlayedSeconds,
    };
  }
}
