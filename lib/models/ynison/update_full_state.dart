import 'dart:convert';

import 'player_state.dart';
import 'device.dart';

final class PlayerUpdateStateMessage {
  final UpdateFullState updateFullState;
  final String rid;
  final int playerActionTimeStamptpMs;
  final String activityInterceptionType;

  PlayerUpdateStateMessage({
    required this.updateFullState,
    required this.rid,
    required this.playerActionTimeStamptpMs,
    required this.activityInterceptionType,
  });

  PlayerUpdateStateMessage.fromJson(Map<String, dynamic> json)
      : updateFullState = UpdateFullState.fromJson(json['update_full_state']),
        rid = json['rid'],
        playerActionTimeStamptpMs = json['player_action_timestamp_ms'],
        activityInterceptionType = json['activity_interception_type'];

  Map<String, dynamic> toJson() {
    return {
      'update_full_state': updateFullState.toJson(),
      'rid': rid,
      'player_action_timestamp_ms': playerActionTimeStamptpMs,
      'activity_interception_type': activityInterceptionType,
    };
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

class UpdateFullState {
  final PlayerState playerState;
  final Device device;
  final bool isCurrentlyActive;

  UpdateFullState({
    required this.playerState,
    required this.device,
    required this.isCurrentlyActive,
  });

  UpdateFullState.fromJson(Map<String, dynamic> json)
      : playerState = PlayerState.fromJson(json['player_state']),
        device = Device.fromJson(json['device']),
        isCurrentlyActive = json['is_currently_active'];

  Map<String, dynamic> toJson() {
    return {
      'player_state': playerState.toJson(),
      'device': device.toJson(),
      'is_currently_active': isCurrentlyActive,
    };
  }
}
