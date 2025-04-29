import 'context_id.dart';
import 'track.dart';

class NewRadioSessionRequest {
  final bool includeTracksInResponse;
  final bool includeWaveModel;
  final List<String> seeds;
  final List<String>? queue;

  NewRadioSessionRequest({
    required this.includeTracksInResponse,
    required this.includeWaveModel,
    required this.seeds,
    this.queue,
  });

  Map<String, dynamic> toJson() {
    return {
      'includeTracksInResponse': includeTracksInResponse,
      'includeWaveModel': includeWaveModel,
      'seeds': seeds,
    };
  }

  NewRadioSessionRequest.fromJson(Map<String, dynamic> json)
      : includeTracksInResponse = json['includeTracksInResponse'],
        includeWaveModel = json['includeWaveModel'],
        seeds = List<String>.from(json['seeds']),
        queue = json['queue'] != null ? List<String>.from(json['queue']) : null;
}

class RadioSession implements ContextId {
  final String id;
  final String batchId;
  final bool isPumpkin;
  final bool isTerminated;
  final List<RadioSeed> acceptedSeeds;
  final RadioSeed descriptionSeed;
  final List<SequenceEntry> sequence;
  final RadioWave wave;

  RadioSession({
    required this.id,
    required this.batchId,
    required this.isPumpkin,
    required this.isTerminated,
    required this.acceptedSeeds,
    required this.descriptionSeed,
    required this.sequence,
    required this.wave,
  });

  RadioSession.fromJson(Map<String, dynamic> json)
      : id = json['radioSessionId'],
        batchId = json['batchId'],
        isPumpkin = json['pumpkin'],
        isTerminated = json['terminated'],
        acceptedSeeds = (json['acceptedSeeds'] as List).map((e) => RadioSeed.fromJson(e)).toList(),
        descriptionSeed = RadioSeed.fromJson(json['descriptionSeed']),
        sequence = (json['sequence'] as List)
            .map((e) => SequenceEntry.fromJson(e, json['batchId']))
            .toList(),
        wave = RadioWave.fromJson(json['wave']);

  @override
  String get contextId => id;
}

class RadioSeed {
  final String tag;
  final String type;
  final String value;

  RadioSeed({required this.tag, required this.type, required this.value});

  Map<String, dynamic> toJson() {
    return {
      'tag': tag,
      'type': type,
      'value': value,
    };
  }

  RadioSeed.fromJson(Map<String, dynamic> json)
      : tag = json['tag'],
        type = json['type'],
        value = json['value'];
}

class SequenceEntry {
  final bool isLiked;
  final String type;
  final Track track;
  final TrackParameters trackParameters;

  SequenceEntry({
    required this.isLiked,
    required this.type,
    required this.track,
    required this.trackParameters,
  });

  SequenceEntry.fromJson(Map<String, dynamic> json, String batchId)
      : isLiked = json['liked'],
        type = json['type'],
        track = Track.fromJson(json['track'], batchId),
        trackParameters = TrackParameters.fromJson(json['trackParameters']);
}

class RadioWave {
  final String idForFrom;
  final String name;
  final List<String> seeds;
  final String stationId;

  RadioWave({
    required this.idForFrom,
    required this.name,
    required this.seeds,
    required this.stationId,
  });

  Map<String, dynamic> toJson() {
    return {
      'idForFrom': idForFrom,
      'name': name,
      'seeds': seeds,
      'stationId': stationId,
    };
  }

  RadioWave.fromJson(Map<String, dynamic> json)
      : idForFrom = json['idForFrom'],
        name = json['name'],
        seeds = List<String>.from(json['seeds']),
        stationId = json['stationId'];
}
