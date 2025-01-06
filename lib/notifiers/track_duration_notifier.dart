import 'package:flutter/foundation.dart';

class TrackDurationNotifier extends ValueNotifier<TrackDurationState> {
  TrackDurationNotifier() : super(_initialValue);
  static const _initialValue = TrackDurationState(
    position: Duration.zero,
    buffered: Duration.zero,
    duration: Duration.zero,
  );
}

class TrackDurationState {
  const TrackDurationState({
    required this.position,
    required this.buffered,
    required this.duration,
  });
  final Duration position;
  final Duration buffered;
  final Duration duration;
}
