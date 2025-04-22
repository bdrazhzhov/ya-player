import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '/helpers/in_memory_cache.dart';

class YandexApiClient {
  final String deviceId;
  final String deviceUuid;
  Locale _locale;
  final _cache = InMemoryCache();

  late final Dio _dio;

  set authToken(String value) {
    if(value.isNotEmpty) {
      _dio.options.headers[HttpHeaders.authorizationHeader] = 'OAuth $value';
    }
    else {
      _dio.options.headers.remove(HttpHeaders.authorizationHeader);
    }
  }

  set locale(Locale value) {
    _locale = value;
    _dio.options.headers[HttpHeaders.acceptLanguageHeader] = _locale.languageCode;
  }

  YandexApiClient({
    required String authToken,
    required this.deviceId,
    required this.deviceUuid,
    locale = const Locale('en')
  }) : _locale = locale {
    final options = BaseOptions(
      baseUrl: 'https://api.music.yandex.net',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: _initHeaders(authToken)
    );
    _dio = Dio(options);

    _addInterceptors();
  }

  void _addInterceptors() {
    _dio.interceptors.add(InterceptorsWrapper(onError: (e, handler){
      debugPrint('Request error: ${e.requestOptions.path}?${e.requestOptions.queryParameters}');
      debugPrint('Request headers: ${e.requestOptions.headers}');

      if (e.response != null) {
        debugPrint(e.response!.data.toString());
        // debugPrint(e.response!.headers.toString());
      } else {
        debugPrint(e.message);
      }

      return handler.next(e);
    }, onRequest: (RequestOptions options, RequestInterceptorHandler handler){
      options.headers['X-Yandex-Music-Client-Now'] = '${DateFormat('y-MM-ddTHH:mm:ss.S').format(DateTime.now().toUtc())}Z';

      return handler.next(options);
    }));
  }

  Map<String, dynamic> _initHeaders(String authToken) {
    Map<String, dynamic> headers = {
      HttpHeaders.acceptLanguageHeader: _locale.languageCode,
      HttpHeaders.userAgentHeader: 'Windows 10',
      'X-Yandex-Music-Client': 'WindowsPhone/4.54',
      'X-Yandex-Music-Device': 'os=Windows.Desktop; os_version=10.0.22621.1992; '
          'manufacturer=Micro-Star International Co., Ltd.; model=MS-0A00; '
          'clid=WindowsPhone; device_id=$deviceId; '
          'uuid=generated-by-music-$deviceUuid'
    };

    if(authToken.isNotEmpty) {
      headers[HttpHeaders.authorizationHeader] = 'OAuth $authToken';
    }
    return headers;
  }

  dynamic get(String path, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Duration? cacheDuration
  }) async {
    final String cacheKey = '$path?${queryParameters?.entries.map((e) => '${e.key}=${e.value}').join('&')}';
    final cacheValue = _cache.get(cacheKey);
    if(cacheValue != null) return cacheValue;

    Response resp = await _dio.get(path,
      options: Options(headers: headers),
      queryParameters: queryParameters
    );

    if(cacheDuration != null) {
      _cache.set(cacheKey, resp.data, expiration: cacheDuration);
    }

    return resp.data;
  }

  Future<Map<String, dynamic>> postJson(String path, {required Map<String, dynamic> data}) async {
    Response resp = await _dio.post(path,
      options: Options(headers: {
        HttpHeaders.contentTypeHeader: Headers.jsonContentType
      }),
      data: jsonEncode(data)
    );

    return resp.data;
  }

  Future<Map<String, dynamic>> postForm(String path, {Map<String, dynamic>? data}) async {
    Response resp = await _dio.post(path,
      options: Options(contentType: Headers.formUrlEncodedContentType),
      data: data
    );

    return resp.data;
  }
}