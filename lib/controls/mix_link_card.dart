import 'package:flutter/material.dart';

import '/models/music_api_types.dart';
import 'yandex_image.dart';

class MixLinkCard extends StatelessWidget {
  final MixLink mixLink;
  final double width;

  const MixLinkCard(this.mixLink, {super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      constraints: BoxConstraints(maxWidth: width, maxHeight: width),
      child: Stack(
        children: [
          YandexImage(
            uriTemplate: mixLink.image,
            size: 200,
            borderRadius: 8
          ),
          Positioned(
            top: width / 2,
            child: SizedBox(
              width: width,
              height: width / 2,
              child: Center(child: Text(mixLink.title))
            ),
          )
        ],
      ),
    );
  }
}
