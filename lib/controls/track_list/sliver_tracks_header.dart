import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SliverTracksHeader extends SliverPersistentHeaderDelegate {
  static const double _height = 40;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: _height,
      child: Container(
        decoration: BoxDecoration(color: theme.colorScheme.surface),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Text(l10n.tracks_headerTrack),
              )
            ),
            SizedBox(width: 50),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 24),
                child: Text(l10n.tracks_headerArtist),
              )
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 24),
                child: Text(l10n.tracks_headerAlbum),
              )
            ),
            // Space for the Like button
            SizedBox(width: 50),
            SizedBox(
              width: 50,
              child: Center(child: Icon(Icons.schedule))
            )
          ],
        ),
      )
    );
  }

  @override
  double get maxExtent => _height;

  @override
  double get minExtent => _height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}
