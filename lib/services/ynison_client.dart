import 'dart:convert';
import 'dart:io';

import 'package:uuid/uuid.dart';

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

  YnisonClient({required String authToken, required String deviceId})
      : _authToken = authToken,
        _deviceId = deviceId {
    _connectToRedirect();
  }

  void _connectToRedirect() {
    print('Connecting to the redirector...');
    WebSocket.connect(
      'wss://ynison.music.yandex.ru/redirector.YnisonRedirectService/GetRedirectToYnison',
      headers: {
        HttpHeaders.authorizationHeader: 'OAuth $_authToken',
        'Origin': 'https://music.yandex.ru',
        'Sec-Websocket-Protocol': 'Bearer,v2,{"Ynison-Device-Id":"$_deviceId","Ynison-Device-Info":'
            '"{\\"app_name\\":\\"Chrome\\",\\"app_version\\":\\"135.0.0.0\\",\\"type\\":1}"}',
      },
    ).then(
      (WebSocket ws) {
        _wsRedirect = ws;
        _wsRedirect.listen(
          (message) {
            print('Redirect received message: $message');
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
          'Sec-Websocket-Protocol':
              'Bearer,v2,{"Ynison-Device-Id":"$_deviceId","Ynison-Device-Info":'
                  '"{\\"app_name\\":\\"Chrome\\",\\"app_version\\":\\"135.0.0.0\\",\\"type\\":1}",'
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
        print('State received message: $message');
        final json = jsonDecode(message);
        final obj = YnisonState.fromJson(json);
      },
      onError: (error) {
        print('Error: $error');
      },
      onDone: () {
        print('State connection closed');
      },
    );

    final version = Version(
      deviceId: _deviceId,
      version: '9021243204784341000',
      timestampMs: '0',
    );

    final messageData = PlayerUpdateStateMessage(
      rid: Uuid().v4().toString(),
      playerActionTimeStamptpMs: 0,
      activityInterceptionType: 'DO_NOT_INTERCEPT_BY_DEFAULT',
      updateFullState: UpdateFullState(
        playerState: PlayerState(
          playerQueue: PlayerQueue(
            currentPlayableIndex: -1,
            entityId: '',
            entityType: 'VARIOUS',
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
        device: Device(
          capabilities: DeviceCapabilities(
            canBePlayer: true,
            canBeRemoteController: false,
            volumeGranularity: 10,
          ),
          info: DeviceInfo(
            deviceId: _deviceId,
            type: 'WEB',
            title: 'Browser Chrome',
            appName: 'Chrome',
            appVersion: '135.0.0.0',
          ),
          isShadow: true,
          volumeInfo: VolumeInfo(volume: 0),
        ),
        isCurrentlyActive: false,
      ),
    );

    final message = messageData.toJsonString();
    print(message);
    _wsPutState.add(message);
  }
}
