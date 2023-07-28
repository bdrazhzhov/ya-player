import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../music_api.dart';
import '../models/music_api_types.dart';

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
          ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: CachedNetworkImage(imageUrl: MusicApi.imageUrl(mixLink.image, '200x200'))
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
