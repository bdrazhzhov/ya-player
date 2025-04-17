import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '/player_state.dart';
import '/window_manager.dart';
import '/dbus/sleep_inhibitor.dart';
import '/dbus/mpris/mpris_player.dart';
import '/audio_player.dart';
import '/player/players_manager.dart';
import '/app_state.dart';
import '/helpers/app_route_observer.dart';
import '/music_api.dart';
import 'preferences.dart';
import 'yandex_api_client.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<WindowManager>(WindowManager());
  getIt.registerSingleton<Preferences>(await _initPreferences());
  getIt.registerSingleton<YandexApiClient>(_initHttpClient());
  getIt.registerSingleton<MusicApi>(_initMusicApi());
  getIt.registerSingleton<DBusClient>(DBusClient.session());
  getIt.registerSingleton<OrgMprisMediaPlayer2>(await _initMpris());
  getIt.registerSingleton<SleepInhibitor>(SleepInhibitor());
  getIt.registerSingleton<AudioPlayer>(AudioPlayer());
  getIt.registerSingleton<PlayersManager>(PlayersManager());
  getIt.registerSingleton<PlayerState>(PlayerState());
  getIt.registerSingleton<AppState>(AppState());
  getIt.registerSingleton<AppRouteObserver>(AppRouteObserver());
}

MusicApi _initMusicApi() {
  final prefs = getIt<Preferences>();

  return MusicApi(prefs.uid ?? 0);
}

Future<Preferences> _initPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  return Preferences(prefs);
}

YandexApiClient _initHttpClient() {
  final prefs = getIt<Preferences>();

  return YandexApiClient(
    authToken: prefs.authToken ?? '',
    deviceId: prefs.deviceId,
    deviceUuid: prefs.deviceUuid,
  );
}

Future<OrgMprisMediaPlayer2> _initMpris() async {
  final dBusClient = getIt<DBusClient>();
  final mpris = OrgMprisMediaPlayer2(
    path: DBusObjectPath('/org/mpris/MediaPlayer2'),
    identity: 'YaPlayer',
  );

  await dBusClient.registerObject(mpris);
  await dBusClient.requestName(
    'org.mpris.MediaPlayer2.YaPlayer.instance$pid',
    flags: {DBusRequestNameFlag.doNotQueue},
  );

  return mpris;
}
