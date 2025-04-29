import '/models/music_api/track.dart';

abstract interface class CanBePlayed {
  String get id;
  String get title;
  String get artist;
  String get albumName;
  bool get isAvailable;
  Duration? get duration;
  ChartItem? get chart;
  String? get version;
  String? get coverUri;
  String get fullId;
  TrackType get type;
}
