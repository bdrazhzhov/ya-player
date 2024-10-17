import 'package:equatable/equatable.dart';

class Station extends Equatable {
  final StationId id;
  final StationId? parentId;
  final String name;
  final StationIcon icon;
  final List<Station> subStations = [];
  late final String _from;

  Station(this.id, this.name, this.icon, this.parentId) {
    String stationId = id.type != 'user' ? '${id.type}_' : '';
    stationId += id.tag;
    _from = 'desktop_win-radio-radio_$stationId-default';
  }

  factory Station.fromJson(Map<String, dynamic> json) {
    StationId? parent = json['parentId'] != null
        ? StationId.fromJson(json['parentId']) : null;

    return Station(StationId.fromJson(json['id']),
        json['name'], StationIcon.fromJson(json['icon']), parent);
  }

  @override
  List<Object> get props => [id];

  String get from => _from;
}

class StationId extends Equatable {
  final String type;
  final String tag;

  const StationId(this.type, this.tag);

  factory StationId.fromJson(Map<String, dynamic> json) {
    return StationId(json['type'], json['tag']);
  }

  @override
  List<Object> get props => [type, tag];

  Map<String, dynamic> toJson() => {
    'type': type,
    'tag': tag
  };
}

class StationIcon {
  final String backgroundColor;
  final String imageUrl;

  StationIcon(this.backgroundColor, this.imageUrl);

  factory StationIcon.fromJson(Map<String, dynamic> json) {
    return StationIcon(json['backgroundColor'], json['imageUrl']);
  }
}
