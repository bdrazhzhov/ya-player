import 'dart:ui';

import '/helpers/color_extension.dart';

class EntityCover {
  final String uri;
  final Color? color;
  final DerivedColors? derivedColors;

  EntityCover({required this.uri, this.color, this.derivedColors});

  factory EntityCover.fromJson(Map<String, dynamic> json) {
    Color? color;
    if (json['color'] != null) {
      color = json['color'].toString().toColor();
    }
    DerivedColors? derivedColors;
    if (json['derivedColors'] != null) {
      derivedColors = DerivedColors.fromJson(json['derivedColors']);
    }

    return EntityCover(
        uri: json['uri'], color: color, derivedColors: derivedColors);
  }
}

class DerivedColors {
  final String average;
  final String waveText;
  final String miniPlayer;
  final String accent;

  DerivedColors({
    required this.average,
    required this.waveText,
    required this.miniPlayer,
    required this.accent,
  });

  factory DerivedColors.fromJson(Map<String, dynamic> json) {
    return DerivedColors(
      average: json['average'],
      waveText: json['waveText'],
      miniPlayer: json['miniPlayer'],
      accent: json['accent'],
    );
  }
}
