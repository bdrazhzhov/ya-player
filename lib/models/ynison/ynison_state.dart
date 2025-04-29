import 'device.dart';
import 'player_state.dart';

class YnisonState {
  final List<YDevice> devices;
  final YPlayerState playerState;
  final String rid;
  final DateTime timestamp;

  YnisonState({
    required this.devices,
    required this.playerState,
    required this.rid,
    required this.timestamp,
  });

  YnisonState.fromJson(Map<String, dynamic> json)
      : devices = (json['devices'] as List).map((e) => YDevice.fromJson(e)).toList(),
        playerState = YPlayerState.fromJson(json['player_state']),
        rid = json['rid'],
        timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(json['timestamp_ms']));
}
