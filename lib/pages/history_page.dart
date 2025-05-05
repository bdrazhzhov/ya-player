import 'package:flutter/material.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '/controls/yandex_image.dart';
import '/helpers/custom_sliver_grid_delegate_extent.dart';
import '/models/music_api/album.dart';
import '/models/music_api/artist.dart';
import '/models/music_api/history.dart';
import '/models/music_api/playlist.dart';
import '/models/music_api/track.dart';
import '/services/music_api.dart';
import '/services/service_locator.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({super.key});

  final _musicApi = getIt<MusicApi>();

  @override
  Widget build(BuildContext context) {
    return MultiSliver(
      children: [
        SliverToBoxAdapter(child: const Text('History')),
        FutureBuilder(
          future: _musicApi.searchHistory(),
          builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
            if(!snapshot.hasData || snapshot.connectionState == ConnectionState.waiting) {
              return SliverToBoxAdapter(child: const Text('Loading...'));
            }

            final items = snapshot.data;

            if(items.isEmpty) {
              return SliverToBoxAdapter(child: const Text('Nothing found'));
            }

            return SliverGrid(
              gridDelegate: CustomSliverGridDelegateExtent(
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                maxCrossAxisExtent: 680,
                height: 60
              ),
              delegate: SliverChildBuilderDelegate(
                (_, index) => buildItem(items[index]),
                childCount: items.length
              )
            );
          },
        ),
        SliverPadding(
          sliver: SliverToBoxAdapter(
            child: OutlinedButton(
              onPressed: (){},
              child: const Text('Clear history')
            )
          ), padding: EdgeInsets.only(top: 50),
        ),
      ],
    );
  }

  Widget buildItem(Object item) {
    switch(item) {
      case Track():
        return ListTile(
          minTileHeight: 60,
          leading: YandexImage(
            width: 50,
            uriTemplate: item.coverUri,
            borderRadius: 4,
          ),
          title: Text(item.title),
          subtitle: Text(item.albumName),
          trailing: SizedBox(
            width: 150,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Icon(Icons.favorite_border),
                const Icon(Icons.heart_broken),
                const Text('01:23'),
              ],
            ),
          ),
        );
      case Artist():
        return ListTile(
          minTileHeight: 60,
          leading: YandexImage(
            width: 50,
            uriTemplate: item.cover!.uri,
            borderRadius: 4,
          ),
          title: Text(item.name),
          subtitle: const Text('Artist'),
          trailing: const Icon(Icons.arrow_forward_ios_outlined),
        );
      case Playlist():
        return Text('Playlist: ${item.title}');
      case Album():
        return Text('Album: ${item.title}');
      case NonMusicAlbum():
        return ListTile(
          minTileHeight: 60,
          leading: YandexImage(
            width: 50,
            uriTemplate: item.coverUri,
            borderRadius: 4
          ),
          title: Text(item.name),
          subtitle: Row(children: [
            const Icon(Icons.favorite_border, size: 14),
            Text(' ${item.likesCount}'),
          ],),
          trailing: const Icon(Icons.arrow_forward_ios_outlined),
        );
      default:
        return const Text('Unknown item');
    }
  }
}
