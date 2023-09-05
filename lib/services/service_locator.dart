import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_state.dart';
import '../helpers/app_route_observer.dart';
import '../music_api.dart';
import 'preferences.dart';
import 'audio_handler.dart';
import 'yandex_api_client.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<Preferences>(await _initPreferences());
  getIt.registerSingleton<MyAudioHandler>(await initAudioService());
  getIt.registerSingleton<YandexApiClient>(_initHttpClient());
  getIt.registerSingleton<MusicApi>(_initMusicApi());
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
    deviceUuid: prefs.deviceUuid
  );
}
