import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class YandexApiClient {
  final String deviceId;
  final String deviceUuid;
  final String lang;

  late final Dio _dio;

  set authToken(String value) {
    if(value.isNotEmpty) {
      _dio.options.headers[HttpHeaders.authorizationHeader] = 'OAuth $value';
    }
    else {
      _dio.options.headers.remove(HttpHeaders.authorizationHeader);
    }
  }

  YandexApiClient({
    required String authToken,
    required this.deviceId,
    required this.deviceUuid,
    this.lang = 'en'
  }) {
    final options = BaseOptions(
      baseUrl: 'https://api.music.yandex.net',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: _initHeaders(authToken)
    );
    _dio = Dio(options);

    _addErrorsInterceptor();
  }

  void _addErrorsInterceptor() {
    _dio.interceptors.add(InterceptorsWrapper(onError: (e, handler){
      debugPrint('Request error: ${e.requestOptions.path}');
      debugPrint('Request headers: ${e.requestOptions.headers}');

      if (e.response != null) {
        debugPrint(e.response!.data.toString());
        // debugPrint(e.response!.headers.toString());
      } else {
        debugPrint(e.message);
      }

      return handler.next(e);
    }));
  }

  Map<String, dynamic> _initHeaders(String authToken) {
    Map<String, dynamic> headers = {
      HttpHeaders.acceptLanguageHeader: lang,
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

  Future<Map<String, dynamic>> get(String path, { Map<String, String>? headers }) async {
    Response resp = await _dio.get(path, options: Options(headers: headers));

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