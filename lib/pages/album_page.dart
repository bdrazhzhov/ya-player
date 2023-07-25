import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ya_player/music_api.dart';

import '../models/music_api/album.dart';
import '../app_state.dart';
import '../models/music_api/track.dart';
import '../services/service_locator.dart';
import '../controls/page_base_layout.dart';

class AlbumPage extends StatelessWidget {
  final Album album;
  final _appState = getIt<AppState>();

  AlbumPage(this.album, {super.key}) {
    _appState.requestAlbumData(album.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PageBaseLayout(
      body: ValueListenableBuilder<AlbumWithTracks?>(
        valueListenable: _appState.albumNotifier,
        builder: (_, albumWithTracks, __) {
          return CustomScrollView(
            slivers: [
              SliverAppBar(
                leading: const SizedBox.shrink(),
                pinned: true,
                collapsedHeight: 60,
                expandedHeight: 200,
                // flexibleSpace: buildFlexibleSpaceBar(),
                flexibleSpace: _CustomFlexibleSpace(album: album),
              ),
              SliverPersistentHeader(
                delegate: _TracksHeader(),
                pinned: true,
              ),

              if(albumWithTracks != null) SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 40, right: 40),
                  child: Table(
                    columnWidths: const <int, TableColumnWidth>{
                      0: FixedColumnWidth(50),
                      1: FlexColumnWidth(),
                      2: FixedColumnWidth(40),
                      3: FixedColumnWidth(50),
                    },
                    children: albumWithTracks.tracks.asMap().entries.map((entry) {
                      Track track = entry.value;
                      int index = entry.key;

                      return TableRow(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.onInverseSurface,
                          border: Border.all(width: 1, color: theme.colorScheme.background)
                        ),
                        children: _tableRowWidgets(index, track)
                      );
                    }).toList(),
                  ),
                ),
              )
            ],
          );
        }
      ),
    );
  }
}

class _CustomFlexibleSpace extends StatelessWidget {
  final Album album;

  const _CustomFlexibleSpace({required this.album});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, _) {
      final settings = context
          .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

      Widget widget;
      if(settings!.currentExtent == settings.minExtent) {
        widget = Padding(
          padding: const EdgeInsets.only(left: 44),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2.0),
                  child: CachedNetworkImage(
                      imageUrl: MusicApi.imageUrl(album.ogImage, '300x300').toString()
                  ),
                ),
              ),
              Expanded(child: Text(album.title)),
              ElevatedButton(
                  onPressed: (){},
                  child: const Row(
                      children: [
                        Icon(Icons.play_arrow),
                        Text('Play')
                      ]
                  )
              ),
              ElevatedButton(
                  onPressed: (){},
                  child: const Row(
                      children: [
                        Icon(Icons.favorite),
                        Text('Like')
                      ]
                  )
              )
            ],
          ),
        );
      }
      else {
        double infoBlockHeight = settings.currentExtent - 12;
        if(infoBlockHeight < 100) infoBlockHeight = 100;

        widget = Padding(
        padding: const EdgeInsets.only(left: 56, top: 12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: CachedNetworkImage(
                imageUrl: MusicApi.imageUrl(album.ogImage, '300x300').toString()
              ),
            ),
            const SizedBox(width: 20),
            ClipRect(
              child: Wrap(
                children: [
                  SizedBox(
                    height: infoBlockHeight,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('ALBUM'),
                        Text(album.title),
                        Row(
                          children: [
                            const Text('Artist:'),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text('${album.artists.first.name} · ${album.year}'),
                            ),
                          ],
                        ),
                        Row(children: [
                          ElevatedButton(
                            onPressed: (){},
                            child: const Row(
                              children: [
                                Icon(Icons.play_arrow),
                                Text('Play')
                              ]
                            )
                          ),
                          ElevatedButton(
                            onPressed: (){},
                            child: const Row(
                              children: [
                                Icon(Icons.favorite),
                                Text('Like')
                              ]
                            )
                          )
                        ])
                      ],
                    ),
                  )],
              ),
            )
          ],
        ),
          );
      }

      return widget;
    });
  }

}

List<Widget> _tableRowWidgets(index, track) {
  final df = DateFormat('mm:ss');

  return [
    Center(child: Text('${index + 1}')),
    Padding(
      padding: const EdgeInsets.only(left: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          track.title,
          softWrap: false,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
    const Center(child: Icon(Icons.favorite)),
    Center(
      child: Text(df.format(DateTime.fromMillisecondsSinceEpoch(track.duration!.inMilliseconds, isUtc: true))),
    ),
  ].map((widget) {
    return SizedBox(height: 40, child: widget,);
  }).toList();
}

class _TracksHeader extends SliverPersistentHeaderDelegate {
  static const double _height = 40;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final theme = Theme.of(context);

    return SizedBox(
      height: _height,
      child: Container(
        decoration: BoxDecoration(color: theme.colorScheme.background),
        child: const Padding(
          padding: EdgeInsets.only(left: 40, right: 40),
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Center(child: Text('#'))
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Text('TRACK'),
                )
              ),
              SizedBox(
                width: 50,
                child: Center(child: Icon(Icons.schedule))
              )
            ],
          ),
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
