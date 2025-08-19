import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import 'editable_title.dart';
import 'yandex_image.dart';

enum FlexibleSpaceType {playlist, artist, album}

class FlexibleSpace extends StatelessWidget {
  final String? imageUrl;
  final FlexibleSpaceType type;
  final String title;
  final Widget? subtitle;
  final Widget actions;
  final void Function(String)? onTitleChanged;

  const FlexibleSpace({
    super.key,
    this.imageUrl,
    required this.type,
    required this.title,
    this.subtitle,
    this.onTitleChanged,
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
        spacing: 12,
        children: [
          _buildImage(50, 4),
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
      spacing: 24,
      children: [
        _buildImage(200, 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(typeToTitle[type]!),
              EditableTitle(title: title, onSubmitted: onTitleChanged,),
              if(subtitle != null) subtitle!,
              actions
            ],
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
          width: size,
          borderRadius: borderRadius,
        )
      )
    );
  }
}
