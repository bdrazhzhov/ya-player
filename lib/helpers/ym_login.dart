import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class YmToken {
  final String accessToken;
  final Duration expiresIn;
  final String tokenType;

  YmToken(this.accessToken, this.expiresIn, this.tokenType);

  factory YmToken.fromJson(Map<String, dynamic> json) {
    return YmToken(json['access_token'],
        Duration(seconds: int.parse(json['expires_in'])),
        json['token_type']
    );
  }
}

Future<YmToken?> ymLogin(String login, String password) async {
  final csrfToken = await _step01();
  if(csrfToken == null) {
    debugPrint('No CSRF token');
    return null;
  }

  final step02Data = await _step02(csrfToken, login);
  if(step02Data['status'] != 'ok') {
    debugPrint('Incorrect Step 02 result data');
    return null;
  }

  final step03Data = await _step03(password, step02Data['track_id']!, csrfToken);
  if(step03Data['status'] != 'ok') {
    debugPrint('Incorrect Step 03 result data');
    return null;
  }

  if(!await _step04()) return null;
  final tokenData = await _step05();
  if(tokenData.isNotEmpty) {
    return YmToken.fromJson(tokenData);
  }
  return null;
}

final _client = HttpClient();
final Map<String, Cookie> _cookieStore = {};

void _saveCookies(List<Cookie> cookies) {
  for(final cookie in cookies){
    _cookieStore['${cookie.domain}:${cookie.name}'] = cookie;
  }
}

Future<String?> _step01() async {
  final query = {'origin': 'music_app'};
  final uri = Uri.https('passport.yandex.ru', '/auth', query);
  final request = await _client.getUrl(uri);
  request.cookies.addAll(_cookieStore.values);
  final response = await request.close();
  _saveCookies(response.cookies);
  final stringData = await response.transform(utf8.decoder).join();
  var regexp = RegExp(r'name="csrf_token" value="([a-z0-9]+:[0-9]+)"/>');
  var match = regexp.firstMatch(stringData);
  if(match == null) {
    regexp = RegExp(r'"common":{"csrf":"([a-z0-9]+:[0-9]+)",');
    match = regexp.firstMatch(stringData);
  }

  return match?.group(1);
}

Future<Map<String,dynamic>> _step02(String csrfToken, String login) async {
  final uri = Uri.parse('https://passport.yandex.ru/registration-validations/auth/multi_step/start');
  final request = await _client.postUrl(uri);
  request.cookies.addAll(_cookieStore.values);
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');
  final params = Uri(queryParameters: {
    'csrf_token': csrfToken,
    'login': login,
    'process_uuid': const Uuid().v4(),
    'retpath': 'https://oauth.yandex.ru/authorize?response_type=token&client_id=23cabbbdc6cd418abb4b39c32c41195d',
    'origin': 'music_app'
  }).query;
  request.write(params);
  final response = await request.close();
  _saveCookies(response.cookies);
  final stringData = await response.transform(utf8.decoder).join();

  return jsonDecode(stringData);
}

Future<Map<String,dynamic>> _step03(String password, String trackId, String csrfToken) async {
  final uri = Uri.parse('https://passport.yandex.ru/registration-validations/auth/multi_step/commit_password');
  final request = await _client.postUrl(uri);
  request.cookies.addAll(_cookieStore.values);
  request.headers.set(HttpHeaders.contentTypeHeader, 'application/x-www-form-urlencoded');
  final params = Uri(queryParameters: {
    'csrf_token': csrfToken,
    'track_id': trackId,
    'password': password,
    'retpath': 'https://oauth.yandex.ru/authorize?response_type=token&client_id=23cabbbdc6cd418abb4b39c32c41195d'
  }).query;
  request.write(params);
  final response = await request.close();
  _saveCookies(response.cookies);
  final stringData = await response.transform(utf8.decoder).join();

  return jsonDecode(stringData);
}

Future<bool> _step04() async {
  final query = {
    'url': 'https://oauth.yandex.ru/authorize?response_type=token%26client_id=23cabbbdc6cd418abb4b39c32c41195d'
  };
  final uri = Uri.https('passport.yandex.ru', '/redirect', query);
  final request = await _client.getUrl(uri);
  request.cookies.addAll(_cookieStore.values);
  request.followRedirects = false;
  final response = await request.close();
  final stringData = await response.transform(utf8.decoder).join();

  if(response.statusCode != 302) {
    debugPrint('Step 04 - Incorrect status code: ${response.statusCode}');
    debugPrint('Step 04: $stringData');
    return false;
  }

  _saveCookies(response.cookies);

  return true;
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
