import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

final _client = HttpClient();
final Map<String, Cookie> _cookieStore = {};

Future<void> ymLogin(String login, String password) async {
  final request = await _client.getUrl(Uri.parse('https://oauth.yandex.ru/authorize?response_type=token&client_id=23cabbbdc6cd418abb4b39c32c41195d'));
  final response = await request.close();
  // debugPrint('Start response cookies: ${response.cookies.join('\n')}');
  for(final cookie in response.cookies){
    _cookieStore['${cookie.domain}:${cookie.name}'] = cookie;
  }
  final stringData = await response.transform(utf8.decoder).join();
  // debugPrint(stringData);
  _step00();
}

Future<void> _step00() async {
  final query = {
    'retpath': 'https://oauth.yandex.ru/authorize?response_type=token&client_id=23cabbbdc6cd418abb4b39c32c41195d',
    'noreturn': '1',
    'origin': 'oauth'
  };
  final uri = Uri.https('passport.yandex.ru', '/auth', query);
  final request = await _client.getUrl(uri);
  request.cookies.addAll(_cookieStore.values);
  debugPrint('Step 00 request cookies: ${request.cookies.join('\n')}');
  final response = await request.close();
  debugPrint('Step 00 response cookies: ${response.cookies.join('\n')}');
  final stringData = await response.transform(utf8.decoder).join();
  debugPrint('Step 00: $stringData');
}