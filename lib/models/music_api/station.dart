import 'package:equatable/equatable.dart';

class Station extends Equatable {
  final StationId id;
  final String name;
  final StationIcon icon;

  const Station(this.id, this.name, this.icon);

  factory Station.fromJson(Map<String, dynamic> json) {
    return Station(StationId.fromJson(json['id']),
        json['name'], StationIcon.fromJson(json['icon']));
  }

  @override
  List<Object> get props => [id];
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
