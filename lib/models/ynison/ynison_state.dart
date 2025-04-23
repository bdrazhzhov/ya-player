import 'device.dart';
import 'player_state.dart';

class YnisonState {
  final List<Device> devices;
  final PlayerState playerState;
  final String rid;
  final DateTime timestamp;

  YnisonState({
    required this.devices,
    required this.playerState,
    required this.rid,
    required this.timestamp,
  });

  YnisonState.fromJson(Map<String, dynamic> json)
      : devices = (json['devices'] as List).map((e) => Device.fromJson(e)).toList(),
        playerState = PlayerState.fromJson(json['player_state']),
        rid = json['rid'],
        timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(json['timestamp_ms']));
}
