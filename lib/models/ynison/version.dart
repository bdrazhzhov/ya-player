class Version {
  final String deviceId;
  final int timestampMs;
  final int version;

  Version({required this.deviceId})
      : timestampMs = DateTime.now().millisecondsSinceEpoch,
        version = DateTime.now().microsecondsSinceEpoch * 1000;

  Version.fromJson(Map<String, dynamic> json)
      : deviceId = json['device_id'],
        timestampMs = json['timestamp_ms'] is String ? int.parse(json['timestamp_ms']) : json['timestamp_ms'],
        version = json['version'] is String ? int.parse(json['version']) : json['version'];

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'timestamp_ms': timestampMs,
      'version': version,
    };
  }
}
