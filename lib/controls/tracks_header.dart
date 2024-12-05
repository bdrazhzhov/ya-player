import 'package:flutter/material.dart';

class TracksHeader extends SliverPersistentHeaderDelegate {
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
              SizedBox(
                  width: 50,
                  child: Center(child: Text('#'))
              ),
              Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 6.0),
                    child: Text('TRACK'),
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
