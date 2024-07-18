import 'package:flutter/material.dart';

class SliverTracksHeader extends SliverPersistentHeaderDelegate {
  static const double _height = 40;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);

    return SizedBox(
      height: _height,
      child: Container(
        decoration: BoxDecoration(color: theme.colorScheme.surface),
        child: const Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Text('TRACK'),
              )
            ),
            SizedBox(width: 50),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 24),
                child: Text('ARTIST'),
              )
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.only(left: 24),
                child: Text('ALBUM'),
              )
            ),
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
