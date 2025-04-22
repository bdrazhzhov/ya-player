import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'state_enums.dart';

class Preferences {
  final SharedPreferences _prefs;

  Preferences(this._prefs);

  String? get authToken => _prefs.getString('authToken');
  Future<void> setAuthToken(String value) async =>
      await _prefs.setString('authToken', value);

  int? get uid => _prefs.getInt('uid');
  Future<void> setUid(int value) async => await _prefs.setInt('uid', value);

  int? get expiresIn => _prefs.getInt('expiresAt');
  Future<void> setExpiresAt(int value) async => await _prefs.setInt('expiresAt', value);

  double get volume => _prefs.getDouble('volume') ?? 1;
  Future<void> setVolume(double value) async => await _prefs.setDouble('volume', value);

  List<String> get likedTracks {
    return (_prefs.getString('likedTracks') ?? '').split(',');
  }
  Future<void> setLikedTracks(List<String> value) async {
    final listString = value.join(',');
    await _prefs.setString('likedTracks', listString);
  }

  int get likedTracksRevision => _prefs.getInt('likedTracksRevision') ?? 0;
  Future<void> setLikedTracksRevision(int value) async =>
      await _prefs.setInt('likedTracksRevision', value);

  String get deviceId {
    String? value = _prefs.getString('deviceId');

    if(value == null) {
      value = const Uuid().v4();
      _prefs.setString('deviceId', value);
    }

    return value;
  }

  String get deviceUuid {
    String? value = _prefs.getString('deviceUuid');

    if(value == null) {
      value = const Uuid().v4();
      _prefs.setString('deviceUuid', value);
    }

    return value;
  }

  bool get shuffle => _prefs.getBool('shuffle') ?? false;
  Future<void> setShuffle(bool value) async {
    await _prefs.setBool('shuffle', value);
  }

  static final _repeatModes = {
    RepeatMode.off.toString() : RepeatMode.off,
    RepeatMode.on.toString() : RepeatMode.on,
    RepeatMode.one.toString() : RepeatMode.one,
  };
  RepeatMode get repeat {
    String? value = _prefs.getString('repeat');

    if(value == null) return RepeatMode.off;

    return _repeatModes[value] ?? RepeatMode.off;
  }

  Future<void> setRepeat(RepeatMode value) async {
    await _prefs.setString('repeat', value.toString());
  }

  bool get hideOnClose => _prefs.getBool('hideOnClose') ?? false;
  Future<void> setHideOnClose(bool value) async {
    await _prefs.setBool('hideOnClose', value);
  }

  Locale get locale => Locale(_prefs.getString('locale') ?? 'en');
  Future<void> setLocale(Locale value) async {
    await _prefs.setString('locale', value.languageCode);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
