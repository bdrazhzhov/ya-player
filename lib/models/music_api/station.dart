import 'package:equatable/equatable.dart';

import 'context_id.dart';

class Station extends Equatable implements ContextId {
  final StationId id;
  final StationId? parentId;
  final String name;
  final StationIcon icon;
  final List<Station> subStations = [];
  final Map<String,StationRestrictions2> restrictions2;
  final Map<String,String> settings2;
  late final String _from;

  Station(this.id, this.name, this.icon, this.parentId,
      this.restrictions2, this.settings2) {
    String stationId = id.type != 'user' ? '${id.type}_' : '';
    stationId += id.tag;
    _from = 'desktop_win-radio-radio_$stationId-default';
  }

  factory Station.fromJson(Map<String, dynamic> json, Map<String, dynamic> settingsJson) {
    StationId? parent = json['parentId'] != null
        ? StationId.fromJson(json['parentId']) : null;

    Map<String,StationRestrictions2> restrictions2 = {};
    json['restrictions2'].forEach((k,v) => restrictions2[k] = StationRestrictions2.fromJson(v));

    return Station(StationId.fromJson(json['id']),
        json['name'], StationIcon.fromJson(json['icon']),
        parent, restrictions2, settingsJson.map((k,v) => MapEntry(k, v.toString()))
    );
  }

  @override
  List<Object> get props => [id];

  String get from => _from;

  @override
  String get contextId => id.toString();
}

class StationId extends Equatable {
  final String type;
  final String tag;

  const StationId(this.type, this.tag);

  factory StationId.fromJson(Map<String, dynamic> json) {
    return StationId(json['type'], json['tag']);
  }

  /// Creates StationId object from string in the following format `type:tag`
  factory StationId.fromString(String idString) {
    List<String> items = idString.split(':');

    return StationId(items[0], items[1]);
  }

  @override
  List<Object> get props => [type, tag];

  Map<String, dynamic> toJson() => {
    'type': type,
    'tag': tag
  };

  @override
  String toString() => '$type:$tag';
}

class StationIcon {
  final String backgroundColor;
  final String imageUrl;

  StationIcon(this.backgroundColor, this.imageUrl);

  factory StationIcon.fromJson(Map<String, dynamic> json) {
    return StationIcon(json['backgroundColor'], json['imageUrl']);
  }
}

class StationRestrictions2 {
  final String name;
  final Iterable<PossibleValue> possibleValues;

  StationRestrictions2({required this.name, required this.possibleValues});

  factory StationRestrictions2.fromJson(Map<String, dynamic> json) {
    final List<PossibleValue> possibleValues = [];

    json['possibleValues'].forEach((i) => possibleValues.add(PossibleValue.fromJson(i)));

    return StationRestrictions2(
      name: json['name'],
      possibleValues: possibleValues
    );
  }
}

class PossibleValue {
  final String value;
  final String name;
  final bool unspecified;

  PossibleValue({
    required this.value,
    required this.name,
    this.unspecified = false
  });

  factory PossibleValue.fromJson(Map<String, dynamic> json) {
    return PossibleValue(value: json['value'], name: json['name']);
  }
}
