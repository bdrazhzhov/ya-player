import 'version.dart';

class Device {
  final bool? isOffline;
  final num? volume;
  final DeviceCapabilities capabilities;
  final DeviceInfo info;
  final DeviceSession? session;
  final VolumeInfo volumeInfo;
  final bool? isShadow;

  Device({
    this.isOffline,
    this.volume,
    required this.capabilities,
    required this.info,
    this.session,
    required this.volumeInfo,
    this.isShadow,
  });

  Device.fromJson(Map<String, dynamic> json)
      : isOffline = json['is_offline'],
        volume = json['volume'],
        capabilities = DeviceCapabilities.fromJson(json['capabilities']),
        info = DeviceInfo.fromJson(json['info']),
        session = json['session'] != null ? DeviceSession.fromJson(json['session']) : null,
        volumeInfo = VolumeInfo.fromJson(json['volume_info']),
        isShadow = json['is_shadow'];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'capabilities': capabilities.toJson(),
      'info': info.toJson(),
      'volume_info': volumeInfo.toJson(),
    };

    if (isOffline != null) {
      json['is_offline'] = isOffline;
    }

    if (volume != null) {
      json['volume'] = volume;
    }

    if (session != null) {
      json['session'] = session!.toJson();
    }

    if (isShadow != null) {
      json['is_shadow'] = isShadow;
    }

    return json;
  }
}

class DeviceCapabilities {
  final bool canBePlayer;
  final bool canBeRemoteController;
  final num volumeGranularity;

  DeviceCapabilities({
    required this.canBePlayer,
    required this.canBeRemoteController,
    required this.volumeGranularity,
  });

  DeviceCapabilities.fromJson(Map<String, dynamic> json)
      : canBePlayer = json['can_be_player'],
        canBeRemoteController = json['can_be_remote_controller'],
        volumeGranularity = json['volume_granularity'];

  Map<String, dynamic> toJson() {
    return {
      'can_be_player': canBePlayer,
      'can_be_remote_controller': canBeRemoteController,
      'volume_granularity': volumeGranularity,
    };
  }
}

class DeviceInfo {
  final String appName;
  final String appVersion;
  final String deviceId;
  final String title;
  final String type;

  DeviceInfo({
    required this.appName,
    required this.appVersion,
    required this.deviceId,
    required this.title,
    required this.type,
  });

  DeviceInfo.fromJson(Map<String, dynamic> json)
      : appName = json['app_name'],
        appVersion = json['app_version'],
        deviceId = json['device_id'],
        title = json['title'],
        type = json['type'];

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'app_name': appName,
      'app_version': appVersion,
      'device_id': deviceId,
      'title': title,
      'type': type,
    };

    return json;
  }
}

class DeviceSession {
  final String id;

  DeviceSession({required this.id});

  DeviceSession.fromJson(Map<String, dynamic> json) : id = json['id'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class VolumeInfo {
  final num volume;
  final Version? version;

  VolumeInfo({required this.volume, this.version});

  VolumeInfo.fromJson(Map<String, dynamic> json)
      : volume = json['volume'],
        version = json['version'] != null ? Version.fromJson(json['version']) : null;

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {
      'volume': volume,
    };

    if (version != null) {
      json['version'] = version!.toJson();
    }

    return json;
  }
}
