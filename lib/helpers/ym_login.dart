import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

const String _clientId = '23cabbbdc6cd418abb4b39c32c41195d';
const String _retPath = 'https://oauth.yandex.ru/authorize?response_type=token'
    '&client_id=$_clientId&redirect_uri=https%3A%2F%2Fmusic.yandex.ru%2F'
    '&force_confirm=False&language=en';

String? _csrfToken;
String _trackId = '';

class YmToken {
  final String accessToken;
  final Duration expiresIn;
  final String tokenType;

  YmToken(this.accessToken, this.expiresIn, this.tokenType);

  factory YmToken.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expires_in'] is int ? json['expires_in'] : int.parse(json['expires_in']);

    return YmToken(
      json['access_token'],
      Duration(seconds: expiresIn),
      json['token_type']
    );
  }
}

enum LoginState { needSms, finished, error, unknown }

class LoginResult {
  final Map<String, dynamic> data;
  final LoginState state;

  LoginResult({this.data = const {}, required this.state});
}

Future<LoginResult> ymLogin(String login, String password) async {
  _csrfToken = await _step01();
  if(_csrfToken == null) {
    debugPrint('No CSRF token');
    return LoginResult(state: LoginState.error);
  }

  debugPrint('CSRF token: $_csrfToken');

  final step02Data = await _multiStepStart(login);
  if(step02Data['status'] != 'ok') {
    debugPrint('Incorrect Step 02 result data');
    return LoginResult(state: LoginState.error);
  }

  if(step02Data['can_register'] != null && step02Data['can_register'] as bool) {
    throw 'Account "$login" not found';
  }

  _trackId = step02Data['track_id']!;
  final step03Data = await _commitPassword(password);
  if(step03Data['status'] != 'ok') {
    debugPrint('Incorrect Step 03 result data');
    return LoginResult(state: LoginState.error);
  }
  else if(step03Data['state'] == 'auth_challenge') {
    return await _precessAuthChallenge();
  }

  final step04Data = await _step04();
  if(step04Data['access_token'] != null) {
    return LoginResult(
        state: LoginState.finished,
        data: step04Data
    );
  }

  // if(!await _step04()) return null;
  // final tokenData = await _step05();
  // if(tokenData.isNotEmpty) {
  //   return YmToken.fromJson(tokenData);
  // }
  return LoginResult(state: LoginState.error);
}

Future<LoginResult> finishAuth() async {
  final Map<String, dynamic> result = await _challengeCommit('phone_confirmation');

  if(result['status'] == 'ok') {
    final String stringData = await _authFinish();
    var regexp = RegExp(r'<input type="hidden" name="request_id" value="([a-z0-9]+)"/>');
    var match = regexp.firstMatch(stringData);

    if(match?.group(1) != null) {
      final stringData = await _authAllow(match!.group(1)!);
      return _extractToken(stringData);
    }

    return _extractToken(stringData);
  }
  else if(result['status'] == 'error') {
    throw 'Finish auth error: ${result['errors']}';
  }
  else {
    throw 'Unknown finish auth status: ${result['status']}';
  }
}

LoginResult _extractToken(String stringData) {
  final regexp = RegExp(r"window\.location\.replace\('https://music\.yandex\.ru/#([a-zA-Z0-9&=_]+)'\);");
  var tokenMatch = regexp.firstMatch(stringData);

  if(tokenMatch != null) {
    final String query = tokenMatch.group(1)!;
    Map<String,String> result = Uri.splitQueryString(query);

    if(result['access_token'] != null) {
      return LoginResult(
          state: LoginState.finished,
          data: result
      );
    }
  }

  return LoginResult(state: LoginState.error, data: {'error': 'Could not find token on the page'});
}

Future<LoginResult> _precessAuthChallenge() async {
  final Map<String, dynamic> challengeData = await _challengeSubmit();
  if(challengeData['status'] != 'ok') {
    throw 'Error during challenge submitting: $challengeData';
  }

  final String challengeType = challengeData['challenge']['challengeType'];

  switch(challengeType) {
    case 'mobile_id':
      return LoginResult(state: LoginState.needSms, data: challengeData['challenge']);
    default:
      debugPrint('Unknown challenge type: $challengeType');
  }

  return LoginResult(state: LoginState.unknown);
}

final _client = HttpClient();
final Map<String, Cookie> _cookieStore = {};

void _saveCookies(List<Cookie> cookies) {
  for(final cookie in cookies){
    _cookieStore['${cookie.domain}:${cookie.name}'] = cookie;
  }
}

Future<T> _postFormData<T>(String url, Map<String,dynamic> formData, { Map<String,dynamic>? headers }) async {
  final uri = Uri.parse(url);
  final request = await _client.postUrl(uri);
  request.cookies.addAll(_cookieStore.values);
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');
  headers?.forEach((key, value) { request.headers.set(key, value); });
  final params = Uri(queryParameters: formData).query;
  request.write(params);
  final response = await request.close();
  _saveCookies(response.cookies);
  final stringData = await response.transform(utf8.decoder).join();

  debugPrint('postFormData() response: $stringData');

  dynamic result;

  if(T == String) {
    result = stringData;
  }
  else if(T == Map<String,dynamic>) {
    result = jsonDecode(stringData);
  }
  else {
    throw 'Unsupported type in generic: ${T.runtimeType}';
  }

  return result as T;
}

Future<String?> _step01() async {
  final query = { 'origin': 'music_app', 'retpath': _retPath };
  final uri = Uri.https('passport.yandex.ru', '/auth', query);
  final request = await _client.getUrl(uri);
  request.cookies.addAll(_cookieStore.values);
  request.headers.add('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; WebView/3.0)'
      ' AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.22621');
  final response = await request.close();
  _saveCookies(response.cookies);
  final stringData = await response.transform(utf8.decoder).join();
  // debugPrint(stringData);
  var regexp = RegExp(r'name="csrf_token" value="([a-z0-9]+:[0-9]+)"/>');
  var match = regexp.firstMatch(stringData);
  if(match == null) {
    regexp = RegExp(r'"common":{"csrf":"([a-z0-9]+:[0-9]+)",');
    match = regexp.firstMatch(stringData);
  }

  return match?.group(1);
}

// Future<String?> _step01() async {
//   final query = {'app_platform': 'android'};
//   final uri = Uri.https('passport.yandex.ru', '/am', query);
//   final request = await _client.getUrl(uri);
//   request.cookies.addAll(_cookieStore.values);
//   final response = await request.close();
//   _saveCookies(response.cookies);
//   final stringData = await response.transform(utf8.decoder).join();
//   var regexp = RegExp(r'name="csrf_token" value="([a-z0-9]+:[0-9]+)"/>');
//   var match = regexp.firstMatch(stringData);
//   if(match == null) {
//     regexp = RegExp(r'"common":{"csrf":"([a-z0-9]+:[0-9]+)",');
//     match = regexp.firstMatch(stringData);
//   }
//
//   return match?.group(1);
// }

Future<Map<String,dynamic>> _multiStepStart(String login) {
  return _postFormData<Map<String,dynamic>>(
    'https://passport.yandex.ru/registration-validations/auth/multi_step/start',
    {
      'csrf_token': _csrfToken,
      'login': login,
      'process_uuid': const Uuid().v4(),
      'retpath': 'https://oauth.yandex.ru/authorize?response_type=token&client_id=$_clientId',
      'origin': 'music_app'
    }
  );
}

Future<Map<String,dynamic>> _commitPassword(String password) {
  return _postFormData<Map<String,dynamic>>(
    'https://passport.yandex.ru/registration-validations/auth/multi_step/commit_password',
    {
      'csrf_token': _csrfToken,
      'track_id': _trackId,
      'password': password,
      'retpath': 'https://passport.yandex.ru/am/finish?status=ok&from=Login'
    }
  );
}

Future<Map<String, dynamic>> _challengeSubmit() {
  return _postFormData<Map<String,dynamic>>(
      'https://passport.yandex.ru/registration-validations/auth/challenge/submit',
      {
        'csrf_token': _csrfToken,
        'track_id': _trackId
      }
  );
}

Future<Map<String, dynamic>> requestConfirmationSms(String phoneId) {
  return _postFormData<Map<String,dynamic>>(
    'https://passport.yandex.ru/registration-validations/phone-confirm-code-submit',
    {
      'csrf_token': _csrfToken,
      'track_id': _trackId,
      'phone_id': phoneId,
      'confirm_method': 'by_sms',
      'isCodeWithFormat': 'true'
    },
    headers: {
      'Referer': 'https://passport.yandex.ru/auth/welcome?origin=music_app'
          '&retpath=https%3A%2F%2Foauth.yandex.ru%2Fauthorize%3Fresponse_type%3Dtoken'
          '%26client_id%3D23cabbbdc6cd418abb4b39c32c41195d%26redirect_uri%3D'
          'https%253A%252F%252Fmusic.yandex.ru%252F%26force_confirm%3DFalse%26language%3Den',
      'X-Requested-With': 'XMLHttpRequest',
    }
  );
}

Future<Map<String, dynamic>> checkConfirmationCode(String confirmationCode) {
  return _postFormData<Map<String,dynamic>>(
    'https://passport.yandex.ru/registration-validations/phone-confirm-code',
    {
      'csrf_token': _csrfToken,
      'track_id': _trackId,
      'code': confirmationCode,
    },
    headers: {
      'Referer': 'https://passport.yandex.ru/auth/welcome?origin=music_app'
          '&retpath=https%3A%2F%2Foauth.yandex.ru%2Fauthorize%3Fresponse_type%3Dtoken'
          '%26client_id%3D23cabbbdc6cd418abb4b39c32c41195d%26redirect_uri%3D'
          'https%253A%252F%252Fmusic.yandex.ru%252F%26force_confirm%3DFalse%26language%3Den',
      'X-Requested-With': 'XMLHttpRequest',
    }
  );
}

Future<Map<String, dynamic>> _challengeCommit(String challengeType) {
  return _postFormData<Map<String,dynamic>>(
    'https://passport.yandex.ru/registration-validations/auth/challenge/commit',
    {
      'csrf_token': _csrfToken,
      'track_id': _trackId,
      'challenge': challengeType,
    },
    headers: {
      'Referer': 'https://passport.yandex.ru/auth/welcome?origin=music_app'
          '&retpath=https%3A%2F%2Foauth.yandex.ru%2Fauthorize%3Fresponse_type%3Dtoken'
          '%26client_id%3D23cabbbdc6cd418abb4b39c32c41195d%26redirect_uri%3D'
          'https%253A%252F%252Fmusic.yandex.ru%252F%26force_confirm%3DFalse%26language%3Den',
      'X-Requested-With': 'XMLHttpRequest',
    }
  );
}

Future<String> _authFinish() async {
  final query = { 'track_id': _trackId, 'retpath': _retPath };
  final uri = Uri.https('passport.yandex.ru', '/auth/finish/', query);
  HttpClientRequest request = await _client.getUrl(uri);
  request.cookies.addAll(_cookieStore.values);
  request.headers.add('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; WebView/3.0)'
      ' AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.22621');
  request.headers.add('Referer', 'https://passport.yandex.ru/auth/challenge?origin=music_app'
      '&retpath=https%3A%2F%2Foauth.yandex.ru%2Fauthorize%3Fresponse_type%3Dtoken%26'
      'client_id%3D$_clientId%26'
      'redirect_uri%3Dhttps%253A%252F%252Fmusic.yandex.ru%252F%26force_confirm%3DFalse%26'
      'language%3Den&track_id=$_trackId');
  request.followRedirects = false;
  HttpClientResponse response = await request.close();
  _saveCookies(response.cookies);


  int redirectsCount = 0;

  while(true) {
    String? location = response.headers.value('Location');
    if(location == null || redirectsCount >= 32) return response.transform(utf8.decoder).join();

    request = await _client.getUrl(Uri.parse(location));
    request.cookies.addAll(_cookieStore.values);
    request.headers.add('User-Agent', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; WebView/3.0)'
        ' AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36 Edge/18.22621');
    request.headers.add('Referer', 'https://passport.yandex.ru/auth/challenge?origin=music_app'
        '&retpath=https%3A%2F%2Foauth.yandex.ru%2Fauthorize%3Fresponse_type%3Dtoken%26'
        'client_id%3D$_clientId%26'
        'redirect_uri%3Dhttps%253A%252F%252Fmusic.yandex.ru%252F%26force_confirm%3DFalse%26'
        'language%3Den&track_id=$_trackId');
    request.followRedirects = false;
    response = await request.close();
    _saveCookies(response.cookies);

    redirectsCount += 1;
  }
}

Future<String> _authAllow(String requestId) async {
  final retPath = Uri.https(
    'oauth.yandex.ru',
    '/authorize',
    {
      'response_type': 'token',
      'client_id': _clientId,
      'redirect_uri': 'https://music.yandex.ru/',
      'force_confirm': 'False',
      'language': 'en'
    }
  ).query;

  return _postFormData<String>(
    'https://oauth.yandex.ru/authorize/allow',
    {
      'ret_path': retPath,
      'clientId': _clientId,
      'csrf_token': _csrfToken,
      'request_id': requestId,
      'redirect_uri': 'https://music.yandex.ru/',
      'granted_scopes': [
        'mobile:all', 'login:info', 'login:email', 'login:birthday', 'login:avatar',
        'music:write', 'music:read', 'music:content', 'messenger:music',
        'cloud_api.data:user_data', 'cloud_api.data:app_data', 'social:broker',
        'passport:bind_phone', 'passport:bind_email', 'yadisk:disk', 'iot:view',
        'yastore:publisher', 'quasar:glagol'
      ]
    }
  );
}

// Future<bool> _step04() async {
//   final query = {
//     'url': 'https://oauth.yandex.ru/authorize?response_type=token%26client_id=$_clientId'
//   };
//   final uri = Uri.https('passport.yandex.ru', '/redirect', query);
//   final request = await _client.getUrl(uri);
//   request.cookies.addAll(_cookieStore.values);
//   request.followRedirects = false;
//   final response = await request.close();
//   final stringData = await response.transform(utf8.decoder).join();
//
//   if(response.statusCode != 302) {
//     debugPrint('Step 04 - Incorrect status code: ${response.statusCode}');
//     debugPrint('Step 04: $stringData');
//     return false;
//   }
//
//   _saveCookies(response.cookies);
//
//   return true;
// }

Future<Map<String,dynamic>> _step04() async {
  final String? sessionId = _cookieStore.values.where((c) => c.name == 'Session_id').firstOrNull?.value;
  if(sessionId == null) {
    throw 'Could not get session id from cookies';
  }

  return _postFormData<Map<String,dynamic>>(
      'https://oauth.yandex.ru/token',
      {
        'grant_type': 'sessionid',
        'client_id': _clientId,
        'client_secret': '53bc75238f0c4d08a118e51fe9203300',
        'host': 'yandex.ru'
      }
  );
}

Future<Map<String,String>> _step05() async {
  final query = {
    'response_type': 'token',
    'client_id': _clientId
  };
  final uri = Uri.https('oauth.yandex.ru', '/authorize', query);
  final request = await _client.getUrl(uri);
  request.cookies.addAll(_cookieStore.values);
  final response = await request.close();
  final stringData = await response.transform(utf8.decoder).join();
  _saveCookies(response.cookies);

  var regexp = RegExp(r"window\.location\.replace\('https://music\.yandex\.ru/#([a-zA-Z0-9&=_]+)'\);");
  var match = regexp.firstMatch(stringData);
  Map<String,String> result = {};
  if(match != null) {
    final String query = match.group(1)!;
    result = Uri.splitQueryString(query);
  }

  return result;
}

Future<void> followRedirect(urlPart) async {
  final url = Uri.parse('https://passport.yandex.ru$urlPart');
  debugPrint('Following redirect: $url');

  await launchUrl(url);
}
