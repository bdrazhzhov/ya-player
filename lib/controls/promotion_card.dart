import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/music_api.dart';

import '../models/music_api/promotion.dart';

class PromotionCard extends StatelessWidget {
  final Promotion promotion;
  final double width;

  const PromotionCard(this.promotion, {super.key, required this.width});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: (){},
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: SizedBox(
          width: width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: CachedNetworkImage(
                  width: width,
                  imageUrl: MusicApi.imageUrl(promotion.image, 'orig')
                ),
              ),
              Text(promotion.heading?.toUpperCase() ?? ' ', style: const TextStyle(color: Colors.red)),
              Text(
                promotion.title,
                style: theme.textTheme.bodyLarge,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
              if(promotion.subtitle != null)
                Text(
                  promotion.subtitle!,
                  style: TextStyle(color: theme.colorScheme.outline),
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                )
            ],
          ),
        ),
      ),
    );
  }
}
