import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'yandex_image.dart';

enum FlexibleSpaceType {playlist, artist, album}

class FlexibleSpace extends StatelessWidget {
  final String? imageUrl;
  final FlexibleSpaceType type;
  final String title;
  final Widget? subtitle;
  final Widget actions;

  const FlexibleSpace({
    super.key,
    this.imageUrl,
    required this.type,
    required this.title,
    this.subtitle,
    required this.actions
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Map<FlexibleSpaceType, String> typeToTitle = {
      FlexibleSpaceType.playlist: l10n.playlist,
      FlexibleSpaceType.artist: l10n.artist_artist,
      FlexibleSpaceType.album: l10n.album_album
    };

    final theme = Theme.of(context);
    final settings = context
        .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();
    if (settings!.currentExtent == settings.minExtent) {
      return Row(
        children: [
          _buildImage(50, 4),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            )
          ),
          actions
        ],
      );
    }

    return Row(
      children: [
        _buildImage(200, 8),
        SizedBox(width: 24),
        Flexible(
          child: FittedBox(
            fit: BoxFit.fitHeight,
            clipBehavior: Clip.hardEdge,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(typeToTitle[type]!),
                Text(
                  title,
                  style: theme.textTheme.displayLarge?.copyWith(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                if(subtitle != null) subtitle!,
                actions
              ],
            ),
          ),
        )
      ],
    );
  }

  Widget _buildImage(double size, double? borderRadius) {
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 6,
            offset: Offset(0, 4)
          )
        ]
      ),
      child: FittedBox(
        child: YandexImage(
          uriTemplate: imageUrl,
          size: size,
          borderRadius: borderRadius,
        )
      )
    );
  }
}
