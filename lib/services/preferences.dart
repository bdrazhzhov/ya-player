import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  final SharedPreferences _prefs;

  Preferences(this._prefs);

  String? get authToken => _prefs.getString('authToken');
  Future<void> setAuthToken(String value) async => await _prefs.setString('authToken', value);

  int? get uid => _prefs.getInt('uid');
  Future<void> setUid(int value) async => await _prefs.setInt('uid', value);

  int? get expiresIn => _prefs.getInt('expiresIn');
  Future<void> setExpiresIn(int value) async => await _prefs.setInt('expiresIn', value);

  double get volume => _prefs.getDouble('volume') ?? 1;
  Future<void> setVolume(double value) async => await _prefs.setDouble('volume', value);

  Future<void> clear() async {
    await _prefs.remove('authToken');
    await _prefs.remove('expiresIn');
    await _prefs.remove('volume');
    await _prefs.remove('uid');
  }
}
