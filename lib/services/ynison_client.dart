import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';
import 'package:ya_player/models/play_info.dart';
import 'package:ya_player/services/logger.dart';

import '/models/ynison/redirect_answer.dart';
import '/models/ynison/ynison_state.dart';
import '/models/ynison/device.dart';
import '/models/ynison/player_state.dart';
import '/models/ynison/update_full_state.dart';
import '/models/ynison/version.dart';

class YnisonClient {
  final String? _authToken;
  final String _deviceId;
  late final WebSocket _wsRedirect;
  late final WebSocket _wsPutState;
  final DeviceInfo _deviceInfo;

  final _stateStreamController = StreamController<YnisonState>();
  Stream<YnisonState> get stateStream => _stateStreamController.stream;

  YnisonClient({required String authToken, required String deviceId})
      : _authToken = authToken,
        _deviceId = deviceId,
        _deviceInfo = DeviceInfo.byDefault(deviceId) {
    _connectToRedirect();
  }

  void _connectToRedirect() {
    print('Connecting to the redirector...');
    WebSocket.connect(
      'wss://ynison.music.yandex.ru/redirector.YnisonRedirectService/GetRedirectToYnison',
      headers: {
        HttpHeaders.authorizationHeader: 'OAuth $_authToken',
        'Origin': 'https://music.yandex.ru',
        'Sec-Websocket-Protocol': 'Bearer,v2,{"Ynison-Device-Id":"$_deviceId",'
            '"Ynison-Device-Info":"${_deviceInfo.toJsonString().replaceAll('"', '\\"')}"}',
      },
    ).then(
      (WebSocket ws) {
        _wsRedirect = ws;
        _wsRedirect.listen(
          (message) {
            // print('Redirect received message: $message');
            final json = jsonDecode(message);
            final redirect = RedirectAnswer.fromJson(json);
            _connectToPutState(redirect);
          },
          onError: (error) {
            print('Error: $error');
          },
          onDone: () {
            print('Redirect connection closed');
          },
        );
      },
      onError: (error) {
        print(error.toString());
      },
    );
  }

  void _connectToPutState(RedirectAnswer redirect) async {
    print('Connecting to the player state service...');

    try {
      _wsPutState = await WebSocket.connect(
        'wss://${redirect.host}/ynison_state.YnisonStateService/PutYnisonState',
        headers: {
          HttpHeaders.authorizationHeader: 'OAuth $_authToken',
          'Origin': 'https://music.yandex.ru',
          'Sec-Websocket-Protocol': 'Bearer,v2,{"Ynison-Device-Id":"$_deviceId",'
              '"Ynison-Device-Info":"${_deviceInfo.toJsonString().replaceAll('"', '\\"')}",'
              '"Ynison-Redirect-Ticket":"${redirect.tiket}",'
              '"Ynison-Session-Id":"${redirect.sessionId}"}',
        },
      );
    } catch (error) {
      print(error.toString());
    }

    _wsPutState.pingInterval = redirect.keepAliveParams.time;
    _wsPutState.listen(
      (message) {
        // print('State received message: $message');
        final json = jsonDecode(message);
        try {
          final stateUpdate = YnisonState.fromJson(json);
          _stateStreamController.add(stateUpdate);
        }
        catch (error) {
          logger.e('Error parsing state update:\n$message', error: error);
          return;
        }
      },
      onError: (error) {
        print('Error: $error');
      },
      onDone: () {
        print('State connection closed');
      },
    );

    final version = Version(deviceId: _deviceId);
    final messageData = PlayerUpdateStateMessage(
      rid: Uuid().v4().toString(),
      playerActionTimeStamptpMs: 0,
      activityInterceptionType: 'DO_NOT_INTERCEPT_BY_DEFAULT',
      updateFullState: UpdateFullState(
        playerState: YPlayerState(
          playerQueue: YPlayerQueue(
            currentPlayableIndex: -1,
            entityId: '',
            entityType: PlayInfoContext.various,
            playableList: [],
            options: QueueOptions(repeatMode: 'NONE'),
            entityContext: 'BASED_ON_ENTITY_BY_DEFAULT',
            version: version,
            from: '',
          ),
          status: PlayerStateStatus(
            duration: Duration.zero,
            isPaused: true,
            playbackSpeed: 1,
            progress: Duration.zero,
            version: version,
          ),
        ),
        device: YDevice(
          capabilities: DeviceCapabilities(
            canBePlayer: true,
            canBeRemoteController: false,
            volumeGranularity: 10,
          ),
          info: _deviceInfo,
          isShadow: true,
          volumeInfo: VolumeInfo(volume: 0),
        ),
        isCurrentlyActive: false,
      ),
    );

    final message = messageData.toJsonString();
    // print(message);
    _wsPutState.add(message);
  }

  void sendPlayerUpdate(YPlayerState state) {
    if (_wsPutState.readyState == WebSocket.open) {
      final message = PlayerUpdateStateMessage(
        playerState: state,
        rid: Uuid().v4().toString(),
        playerActionTimeStamptpMs: DateTime.now().millisecondsSinceEpoch,
        activityInterceptionType: 'DO_NOT_INTERCEPT_BY_DEFAULT',
      );
      // logger.i('Send player update: ${message.toJsonString()}');
      _wsPutState.add(message.toJsonString());
    } else {
      logger.w('WebSocket is not open');
    }
  }
}
