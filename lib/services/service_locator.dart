import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_state.dart';
import '../helpers/app_route_observer.dart';
import '../music_api.dart';
import 'preferences.dart';
import 'audio_handler.dart';

GetIt getIt = GetIt.instance;

Future<void> setupServiceLocator() async {
  getIt.registerSingleton<Preferences>(await _initPreferences());
  getIt.registerSingleton<MyAudioHandler>(await initAudioService());
  getIt.registerSingleton<MusicApi>(await _initMusicApi());
  getIt.registerSingleton<AppState>(AppState());
  getIt.registerSingleton<AppRouteObserver>(AppRouteObserver());
}

Future<MusicApi> _initMusicApi() async {
  final prefs = getIt<Preferences>();

  return MusicApi(prefs.authToken ?? '', prefs.uid ?? 0);
}

Future<Preferences> _initPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  return Preferences(prefs);
}
