import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class YandexImage extends StatelessWidget {
  final String uriPlaceholder;
  final double size;
  final double? borderRadius;
  late final String _url;
  
  static final _sizes = [30, 40, 50, 60, 70, 80, 100, 120, 150, 160, 200, 260,
    300, 360, 400, 460, 480, 520, 600, 700, 720, 800, 960, 1000, 1080];

  YandexImage({
    super.key,
    required this.uriPlaceholder,
    required this.size,
    this.borderRadius
  }) {
    int realSize = size.round();

    for(var i = _sizes.length - 1; i > 0; i--) {
      if(_sizes[i] >= realSize) continue;

      realSize = _sizes[i + 1];
      break;
    }

    final sizeString = realSize.toString();
    final dimensions = '${sizeString}x$sizeString';
    _url = 'https://${uriPlaceholder.replaceAll('%%', dimensions)}';
  }

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      memCacheWidth: size.toInt(),
      imageUrl: _url
    );

    if(borderRadius != null) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: image,
      );
    }

    return image;
  }
}
