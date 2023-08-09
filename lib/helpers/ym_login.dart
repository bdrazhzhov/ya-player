import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

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

class LoginResult {
  final YmToken? tokenData;
  final String? redirectPath;

  LoginResult({this.tokenData, this.redirectPath});
}

Future<LoginResult> ymLogin(String login, String password) async {
  final csrfToken = await _step01();
  if(csrfToken == null) {
    debugPrint('No CSRF token');
    return LoginResult();
  }

  final step02Data = await _multiStepStart(csrfToken, login);
  if(step02Data['status'] != 'ok') {
    debugPrint('Incorrect Step 02 result data');
    return LoginResult();
  }

  if(step02Data['can_register'] != null && step02Data['can_register'] as bool) {
    throw 'Account "$login" not found';
  }

  final String trackId = step02Data['track_id']!;
  final step03Data = await _commitPassword(password, trackId, csrfToken);
  if(step03Data['status'] != 'ok') {
    debugPrint('Incorrect Step 03 result data');
    return LoginResult();
  }
  else if(step03Data['state'] == 'auth_challenge' && step03Data['redirect_url'] != null) {
    final Map<String, dynamic> challengeData = await _challengeSubmit(trackId, csrfToken);
    if(challengeData['status'] != 'ok') {
      throw 'Error during challenge submitting: $challengeData';
    }

    final String challengeType = challengeData['challenge']['challengeType'];

    switch(challengeType) {
      case 'mobile_id':
        final int phoneId = challengeData['challenge']['phoneId'];
        final Map<String, dynamic> data = await _requestConfirmationSms(trackId, csrfToken, phoneId);
        if(data['status'] != 'ok') {
          throw 'Error during phone confirmation code submitting: $data';
        }
        // TODO: need to show text field for confirmation code input
      default:
        debugPrint('Unknown challenge type: $challengeType');
    }

    return LoginResult(redirectPath: step03Data['redirect_url']);
  }

  final step04Data = await _step04();
  if(step04Data['access_token'] != null) {
    return LoginResult(tokenData: YmToken.fromJson(step04Data));
  }

  // if(!await _step04()) return null;
  // final tokenData = await _step05();
  // if(tokenData.isNotEmpty) {
  //   return YmToken.fromJson(tokenData);
  // }
  return LoginResult();
}

final _client = HttpClient();
final Map<String, Cookie> _cookieStore = {};

void _saveCookies(List<Cookie> cookies) {
  for(final cookie in cookies){
    _cookieStore['${cookie.domain}:${cookie.name}'] = cookie;
  }
}

Future<Map<String,dynamic>> _postFormData(String url, Map<String,dynamic> formData) async {
  final uri = Uri.parse(url);
  final request = await _client.postUrl(uri);
  request.cookies.addAll(_cookieStore.values);
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');
  final params = Uri(queryParameters: formData).query;
  request.write(params);
  final response = await request.close();
  _saveCookies(response.cookies);
  final stringData = await response.transform(utf8.decoder).join();

  debugPrint('postFormData() response: $stringData');

  return jsonDecode(stringData);
}

Future<String?> _step01() async {
  final query = {'origin': 'music_app'};
  final uri = Uri.https('passport.yandex.ru', '/auth', query);
  final request = await _client.getUrl(uri);
  request.cookies.addAll(_cookieStore.values);
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

Future<Map<String,dynamic>> _multiStepStart(String csrfToken, String login) {
  return _postFormData(
    'https://passport.yandex.ru/registration-validations/auth/multi_step/start',
    {
      'csrf_token': csrfToken,
      'login': login,
      'process_uuid': const Uuid().v4(),
      'retpath': 'https://oauth.yandex.ru/authorize?response_type=token&client_id=23cabbbdc6cd418abb4b39c32c41195d',
      'origin': 'music_app'
    }
  );
}

// Future<Map<String,dynamic>> _step02(String csrfToken, String login) async {
//   final uri = Uri.parse('https://passport.yandex.ru/registration-validations/auth/multi_step/start');
//   final request = await _client.postUrl(uri);
//   request.cookies.addAll(_cookieStore.values);
//   request.headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');
//   final params = Uri(queryParameters: { 'csrf_token': csrfToken, 'login': login }).query;
//   request.write(params);
//   final response = await request.close();
//   _saveCookies(response.cookies);
//   final stringData = await response.transform(utf8.decoder).join();
//
//   return jsonDecode(stringData);
// }

Future<Map<String,dynamic>> _commitPassword(String password, String trackId, String csrfToken) {
  return _postFormData(
    'https://passport.yandex.ru/registration-validations/auth/multi_step/commit_password',
    {
      'csrf_token': csrfToken,
      'track_id': trackId,
      'password': password,
      'retpath': 'https://passport.yandex.ru/am/finish?status=ok&from=Login'
    }
  );
}

Future<Map<String, dynamic>> _challengeSubmit(String trackId, String csrfToken) {
  return _postFormData(
      'https://passport.yandex.ru/registration-validations/auth/challenge/submit',
      {
        'csrf_token': csrfToken,
        'track_id': trackId
      }
  );
}

Future<Map<String, dynamic>> _requestConfirmationSms(String trackId, String csrfToken, int phoneId) {
  return _postFormData(
      'https://passport.yandex.ru/registration-validations/phone-confirm-code-submit',
      {
        'csrf_token': csrfToken,
        'track_id': trackId,
        'phone_id': phoneId,
        'confirm_method': 'by_sms',
        'isCodeWithFormat': 'true'
      }
  );
}

Future<Map<String, dynamic>> _checkConfirmationCode(String trackId, String csrfToken, String confirmationCode) {
  return _postFormData(
      'https://passport.yandex.ru/registration-validations/phone-confirm-code',
      {
        'csrf_token': csrfToken,
        'track_id': trackId,
        'code': confirmationCode,
      }
  );
}

Future<Map<String, dynamic>> _challengeCommit(String trackId, String csrfToken, String challengeType) {
  return _postFormData(
      'https://passport.yandex.ru/registration-validations/phone-confirm-code',
      {
        'csrf_token': csrfToken,
        'track_id': trackId,
        'challenge': challengeType,
      }
  );
}

// Future<bool> _step04() async {
//   final query = {
//     'url': 'https://oauth.yandex.ru/authorize?response_type=token%26client_id=23cabbbdc6cd418abb4b39c32c41195d'
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

  return _postFormData(
      'https://oauth.yandex.ru/token',
      {
        'grant_type': 'sessionid',
        'client_id': '23cabbbdc6cd418abb4b39c32c41195d',
        'client_secret': '53bc75238f0c4d08a118e51fe9203300',
        'host': 'yandex.ru'
      }
  );
}

Future<Map<String,String>> _step05() async {
  final query = {
    'response_type': 'token',
    'client_id': '23cabbbdc6cd418abb4b39c32c41195d'
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
