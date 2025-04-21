import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:ya_player/helpers/color_extension.dart';

final class Genre extends Equatable {
  final String id;
  final int weight;
  final bool composerTop;
  final String? urlPart;
  final String title;
  final String? fullTitle;
  final Map<String, GenreTitle> titles;
  final Color? color;
  final Map<String, String> images;
  final bool showInMenu;
  final List<Genre> subGenres;
  final List<int>? showInRegions;
  final List<int>? hideInRegions;

  const Genre({
    required this.id,
    required this.weight,
    required this.composerTop,
    required this.urlPart,
    required this.title,
    this.fullTitle,
    required this.titles,
    this.color,
    required this.images,
    required this.showInMenu,
    required this.subGenres,
    this.showInRegions,
    this.hideInRegions,
  });

  @override
  List<Object?> get props => [id];

  factory Genre.fromJson(Map<String, dynamic> json) {
    final Map<String, GenreTitle> titles = {};
    for (final String key in json['titles'].keys) {
      titles[key] = GenreTitle.fromJson(json['titles'][key]);
    }

    final Map<String, String> images = {};
    if(json['images'] != null) {
      for (final String key in json['images'].keys) {
        images[key] = json['images'][key];
      }
    }

    final List<Genre> subGenres = [];
    if (json['subGenres'] != null) {
      for (final item in json['subGenres']) {
        subGenres.add(Genre.fromJson(item));
      }
    }

    return Genre(
      id: json['id'],
      weight: json['weight'],
      composerTop: json['composerTop'],
      urlPart: json['urlPart'],
      title: json['title'],
      fullTitle: json['fullTitle'],
      titles: titles,
      color: json['color']?.toString().toColor(),
      images: images,
      showInMenu: json['showInMenu'],
      subGenres: subGenres,
      showInRegions: json['showInRegions'] != null
          ? List<int>.from(json['showInRegions'])
          : null,
      hideInRegions: json['hideInRegions'] != null
          ? List<int>.from(json['hideInRegions'])
          : null,
    );
  }
}

final class GenreTitle {
  final String title;
  final String? fullTitle;

  GenreTitle({required this.title, required this.fullTitle});

  factory GenreTitle.fromJson(Map<String, dynamic> json) {
    return GenreTitle(
      title: json['title'],
      fullTitle: json['fullTitle'],
    );
  }
}

final class GenreRadioIcon {
  final Color backgroundColor;
  final String imageUrl;

  GenreRadioIcon({required this.backgroundColor, required this.imageUrl});

  factory GenreRadioIcon.fromJson(Map<String, dynamic> json) {
    return GenreRadioIcon(
      backgroundColor: Color(int.parse(json['backgroundColor'])),
      imageUrl: json['imageUrl'],
    );
  }
}
