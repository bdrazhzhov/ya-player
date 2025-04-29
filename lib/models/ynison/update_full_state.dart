import 'dart:convert';

import 'player_state.dart';
import 'device.dart';

final class PlayerUpdateStateMessage {
  final UpdateFullState? updateFullState;
  final YPlayerState? playerState;
  final String rid;
  final int playerActionTimeStamptpMs;
  final String activityInterceptionType;

  PlayerUpdateStateMessage({
    this.updateFullState,
    this.playerState,
    required this.rid,
    required this.playerActionTimeStamptpMs,
    required this.activityInterceptionType,
  });

  PlayerUpdateStateMessage.fromJson(Map<String, dynamic> json)
      : updateFullState = json['update_full_state'] != null ? UpdateFullState.fromJson(json['update_full_state']) : null,
        playerState = json['player_state'] != null ? YPlayerState.fromJson(json['player_state']) : null,
        rid = json['rid'],
        playerActionTimeStamptpMs = json['player_action_timestamp_ms'],
        activityInterceptionType = json['activity_interception_type'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'rid': rid,
      'player_action_timestamp_ms': playerActionTimeStamptpMs,
      'activity_interception_type': activityInterceptionType,
    };

    if (updateFullState != null) {
      json['update_full_state'] = updateFullState!.toJson();
    }

    if (playerState != null) {
      json['update_player_state'] = { 'player_state': playerState!.toJson()};
    }

    return json;
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }
}

class UpdateFullState {
  final YPlayerState playerState;
  final YDevice device;
  final bool isCurrentlyActive;

  UpdateFullState({
    required this.playerState,
    required this.device,
    required this.isCurrentlyActive,
  });

  UpdateFullState.fromJson(Map<String, dynamic> json)
      : playerState = YPlayerState.fromJson(json['player_state']),
        device = YDevice.fromJson(json['device']),
        isCurrentlyActive = json['is_currently_active'];

  Map<String, dynamic> toJson() {
    return {
      'player_state': playerState.toJson(),
      'device': device.toJson(),
      'is_currently_active': isCurrentlyActive,
    };
  }
}
