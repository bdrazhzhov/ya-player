class Version {
  final String deviceId;
  final String timestampMs;
  final String version;

  Version({
    required this.deviceId,
    required this.timestampMs,
    required this.version,
  });

  Version.fromJson(Map<String, dynamic> json)
      : deviceId = json['device_id'],
        timestampMs = json['timestamp_ms'],
        version = json['version'];

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'timestamp_ms': timestampMs,
      'version': version,
    };
  }
}
