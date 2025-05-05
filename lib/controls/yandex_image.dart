import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class YandexImage extends StatelessWidget {
  final String? uriTemplate;
  late final double? _width;
  late final double? _height;
  final double? borderRadius;
  final Widget placeholder;
  late final String _url;
  
  static final _sizes = [30, 40, 50, 60, 70, 80, 100, 120, 150, 160, 200, 260,
    300, 360, 400, 460, 480, 520, 600, 700, 720, 800, 960, 1000, 1080];

  YandexImage({
    super.key,
    this.uriTemplate,
    double? width,
    double? height,
    this.borderRadius,
    this.placeholder = const DefaultImagePlaceholder()
  }) {
    if(uriTemplate == null) return;
    if(width == null && height == null) {
      _width = 160;
      _height = 160;
    }
    else if(width == null && height != null) {
      _width = height;
      _height = height;
    }
    else if(width != null && height == null) {
      _width = width;
      _height = width;
    }
    else {
      _width = width;
      _height = height;
    }

    int realSize = _width!.round();

    for(var i = _sizes.length - 1; i > 0; i--) {
      if(_sizes[i] >= realSize) continue;

      realSize = _sizes[i + 1];
      break;
    }

    final sizeString = realSize.toString();
    final dimensions = '${sizeString}x$sizeString';
    _url = 'https://${uriTemplate!.replaceAll('%%', dimensions)}';
  }

  @override
  Widget build(BuildContext context) {
    Widget image;

    if(uriTemplate == null) {
      image = DefaultImagePlaceholder();
    }
    else {
      image = CachedNetworkImage(
        width: _width,
        height: _height,
        memCacheWidth: _width!.toInt(),
        memCacheHeight: _height!.toInt(),
        fit: BoxFit.fitWidth,
        placeholder: (context, url) => placeholder,
        errorWidget: (context, url, error) => const Icon(Icons.error),
        imageUrl: _url,
      );
    }

    if(borderRadius != null) {
      image = ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius!),
        child: image,
      );
    }

    return image;
  }
}

class DefaultImagePlaceholder extends StatelessWidget {
  const DefaultImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset('assets/svg/track_placeholder.svg');
  }
}

