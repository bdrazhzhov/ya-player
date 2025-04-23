import 'version.dart';

class PlayerState {
  final PlayerQueue playerQueue;
  final PlayerStateStatus status;

  PlayerState({required this.playerQueue, required this.status});

  PlayerState.fromJson(Map<String, dynamic> json)
      : playerQueue = PlayerQueue.fromJson(json['player_queue']),
        status = PlayerStateStatus.fromJson(json['status']);

  Map<String,dynamic> toJson() {
    return {
      'player_queue': playerQueue.toJson(),
      'status': status.toJson(),
    };
  }
}

class PlayerQueue {
  final int currentPlayableIndex;
  final String entityContext;
  final String entityId;
  final String entityType;
  final String? from;
  final AddingOptions? addingOptions;
  final QueueOptions options;
  final List<Playable> playableList;
  final QueueInfo? queue;
  final Version version;

  PlayerQueue({
    required this.currentPlayableIndex,
    required this.entityContext,
    required this.entityId,
    required this.entityType,
    this.from,
    this.addingOptions,
    required this.options,
    required this.playableList,
    this.queue,
    required this.version,
  });

  PlayerQueue.fromJson(Map<String, dynamic> json)
      : currentPlayableIndex = json['current_playable_index'],
        entityContext = json['entity_context'],
        entityId = json['entity_id'],
        entityType = json['entity_type'],
        from = json['from_optional'],
        addingOptions = json['adding_options_optional'] != null
            ? AddingOptions.fromJson(json['adding_options_optional'])
            : null,
        options = QueueOptions.fromJson(json['options']),
        playableList = (json['playable_list'] as List).map((e) => Playable.fromJson(e)).toList(),
        queue = QueueInfo.fromJson(json['queue']),
        version = Version.fromJson(json['version']);

  Map<String,dynamic> toJson() {
    Map<String,dynamic> json = {
      'current_playable_index': currentPlayableIndex,
      'entity_context': entityContext,
      'entity_id': entityId,
      'entity_type': entityType,
      'from_optional': from ?? '',
      'options': options.toJson(),
      'playable_list': playableList.map((e) => e.toJson()).toList(),
      'version': version.toJson(),
    };

    if(addingOptions != null) {
      json['adding_options_optional'] = addingOptions!.toJson();
    }

    if(queue != null) {
      json['queue'] = queue!.toJson();
    }

    return json;
  }
}

class AddingOptions {
  final RadioOptions radioOptions;

  AddingOptions({required this.radioOptions});

  AddingOptions.fromJson(Map<String, dynamic> json)
      : radioOptions = RadioOptions.fromJson(json['radio_options']);

  Map<String,dynamic> toJson() {
    return {
      'radio_options': radioOptions.toJson(),
    };
  }
}

class RadioOptions {
  final String sessionId;

  RadioOptions({required this.sessionId});

  RadioOptions.fromJson(Map<String, dynamic> json) : sessionId = json['session_id'];

  Map<String,dynamic> toJson() {
    return {
      'session_id': sessionId,
    };
  }
}

class QueueOptions {
  final String repeatMode;

  QueueOptions({required this.repeatMode});

  QueueOptions.fromJson(Map<String, dynamic> json) : repeatMode = json['repeat_mode'];

  Map<String,dynamic> toJson() {
    return {
      'repeat_mode': repeatMode,
    };
  }
}

class Playable {
  final String? albumId;
  final String? coverUrl;
  final String from;
  final String playableId;
  final String playableType;
  final String title;
  final PlayableTrackInfo trackInfo;

  Playable({
    this.albumId,
    this.coverUrl,
    required this.from,
    required this.playableId,
    required this.playableType,
    required this.title,
    required this.trackInfo,
  });

  Playable.fromJson(Map<String, dynamic> json)
      : albumId = json['album_id_optional'],
        coverUrl = json['cover_url_optional'],
        from = json['from'],
        playableId = json['playable_id'],
        playableType = json['playable_type'],
        title = json['title'],
        trackInfo = PlayableTrackInfo.fromJson(json['track_info']);

  Map<String,dynamic> toJson() {
    Map<String,dynamic> json = {
      'from': from,
      'playable_id': playableId,
      'playable_type': playableType,
      'title': title,
      'track_info': trackInfo.toJson(),
    };

    if(albumId != null) {
      json['album_id_optional'] = albumId;
    }

    if(coverUrl != null) {
      json['cover_url_optional'] = coverUrl;
    }

    return json;
  }
}

class PlayableTrackInfo {
  final num trackSourceKey;

  PlayableTrackInfo({required this.trackSourceKey});

  PlayableTrackInfo.fromJson(Map<String, dynamic> json) : trackSourceKey = json['track_source_key'];

  Map<String,dynamic> toJson() {
    return {
      'track_source_key': trackSourceKey,
    };
  }
}

class QueueInfo {
  final WaveQueue waveQueue;

  QueueInfo({required this.waveQueue});

  QueueInfo.fromJson(Map<String, dynamic> json)
      : waveQueue = WaveQueue.fromJson(json['wave_queue']);

  Map<String,dynamic> toJson() {
    return {
      'wave_queue': waveQueue.toJson(),
    };
  }
}

class WaveQueue {
  final EntityOptions entityOptions;
  final int livePlayableIndex;
  final List<Playable> recommendedPlayableList;

  WaveQueue({
    required this.entityOptions,
    required this.livePlayableIndex,
    required this.recommendedPlayableList,
  });

  WaveQueue.fromJson(Map<String, dynamic> json)
      : entityOptions = EntityOptions.fromJson(json['entity_options']),
        livePlayableIndex = json['live_playable_index'],
        recommendedPlayableList = (json['recommended_playable_list'] as List)
            .map((e) => Playable.fromJson(e))
            .toList();

  Map<String,dynamic> toJson() {
    return {
      'entity_options': entityOptions.toJson(),
      'live_playable_index': livePlayableIndex,
      'recommended_playable_list': recommendedPlayableList.map((e) => e.toJson()).toList(),
    };
  }
}

class EntityOptions {
  final List<TrackSource> trackSources;
  final RadioOptions? waveEntity;

  EntityOptions({
    required this.trackSources,
    required this.waveEntity,
  });

  factory EntityOptions.fromJson(Map<String, dynamic> json) {
    final waveEntity = json['wave_entity_optional'] != null
        ? RadioOptions.fromJson(json['wave_entity_optional'])
        : null;
    final List<TrackSource> trackSources = [];
    json['track_sources']?.forEach((e) => trackSources.add(TrackSource.fromJson(e)));

    return EntityOptions(
      trackSources: trackSources,
      waveEntity: waveEntity,
    );
  }

  Map<String,dynamic> toJson() {
    return {
      'track_sources': trackSources.map((e) => e.toJson()).toList(),
      'wave_entity_optional': waveEntity?.toJson(),
    };
  }
}

class TrackSource {
  final int key;
  final WaveSource? waveSource;
  final PhonotekaSource? phonotekaSource;

  TrackSource({required this.key, this.waveSource, this.phonotekaSource});

  TrackSource.fromJson(Map<String, dynamic> json)
      : key = json['key'],
        waveSource = json['wave_source'] != null ? WaveSource.fromJson(json['wave_source']) : null,
        phonotekaSource = json['phonoteka_source'] != null ? PhonotekaSource.fromJson(json['phonoteka_source']) : null;

  Map<String,dynamic> toJson() {
    Map<String,dynamic> json = {
      'key': key,
    };

    if(waveSource != null) {
      json['wave_source'] = waveSource!.toJson();
    }

    if(phonotekaSource != null) {
      json['phonoteka_source'] = phonotekaSource!.toJson();
    }

    return json;
  }
}

class WaveSource {
  WaveSource.fromJson(Map<String, dynamic> json);
  Map<String,dynamic> toJson() {
    return {};
  }
}

enum PhonotekaSourceType { unknown, playlist, album, artist }

class PhonotekaSource {
  final String entityContext;
  final PhonotekaSourceType type;
  final String id;

  PhonotekaSource({required this.entityContext, required this.type, required this.id,});

  factory PhonotekaSource.fromJson(Map<String, dynamic> json) {
    var type = PhonotekaSourceType.unknown;
    String id = '';
    if(json['playlist_id'] != null) {
      type = PhonotekaSourceType.playlist;
      id = json['playlist_id']['id'];
    }
    else if(json['album_id'] != null) {
      type = PhonotekaSourceType.album;
      id = json['album_id']['id'];
    }
    else if(json['artist_id'] != null) {
      type = PhonotekaSourceType.artist;
      id = json['artist_id']['id'];
    }
    else {
      print('Unknown PhonotekaSource type: $json');
    }

    return PhonotekaSource(entityContext: json['entity_context'], type: type, id: id);
  }

  Map<String,dynamic> toJson() {
    Map<String,dynamic> json = {
      'entity_context': entityContext,
      'type': type.toString(),
      'id': id,
    };

    if(type == PhonotekaSourceType.playlist) {
      json['playlist_id'] = {'id': id};
    }
    else if(type == PhonotekaSourceType.album) {
      json['album_id'] = {'id': id};
    }
    else if(type == PhonotekaSourceType.artist) {
      json['artist_id'] = {'id': id};
    }

    return json;
  }
}

class PlayerStateStatus {
  final Duration duration;
  final bool isPaused;
  final double playbackSpeed;
  final Duration progress;
  final Version version;

  PlayerStateStatus({
    required this.duration,
    required this.isPaused,
    required this.playbackSpeed,
    required this.progress,
    required this.version,
  });

  PlayerStateStatus.fromJson(Map<String, dynamic> json)
      : duration = Duration(milliseconds: int.parse(json['duration_ms'])),
        isPaused = json['paused'],
        playbackSpeed = json['playback_speed'],
        progress = Duration(milliseconds: int.parse(json['progress_ms'])),
        version = Version.fromJson(json['version']);

  Map<String,dynamic> toJson() {
    return {
      'duration_ms': duration.inMilliseconds,
      'paused': isPaused,
      'playback_speed': playbackSpeed,
      'progress_ms': progress.inMilliseconds,
      'version': version.toJson(),
    };
  }
}
