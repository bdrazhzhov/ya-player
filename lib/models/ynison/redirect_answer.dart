class RedirectAnswer {
  final String host;
  final String sessionId;
  final String tiket;
  final KeepAliveParams keepAliveParams;

  RedirectAnswer({
    required this.host,
    required this.sessionId,
    required this.tiket,
    required this.keepAliveParams,
  });

  RedirectAnswer.fromJson(Map<String, dynamic> json)
      : host = json['host'],
        sessionId = json['session_id'],
        tiket = json['redirect_ticket'],
        keepAliveParams = KeepAliveParams.fromJson(json['keep_alive_params']);
}

class KeepAliveParams {
  final Duration time;
  final Duration timeOut;

  KeepAliveParams({
    required this.time,
    required this.timeOut,
  });

  KeepAliveParams.fromJson(Map<String, dynamic> json)
      : time = Duration(seconds: json['keep_alive_time_seconds']),
        timeOut = Duration(seconds: json['keep_alive_timeout_seconds']);
}
