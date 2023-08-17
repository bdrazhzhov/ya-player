import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controls/album_card.dart';
import '../controls/artist_card.dart';
import '../controls/track_list.dart';
import '../helpers/playback_queue.dart';
import '../models/music_api/artist.dart';
import '../models/music_api/artist_info.dart';
import '../controls/page_base_layout.dart';
import '../services/service_locator.dart';
import '../music_api.dart';

class ArtistPage extends StatelessWidget {
  late final Future<ArtistInfo> artistInfo;
  final _musicApi = getIt<MusicApi>();
  final LikedArtist artist;

  ArtistPage(this.artist, {super.key}) {
    artistInfo = _musicApi.artistInfo(artist.id);
  }

  @override
  Widget build(BuildContext context) {
    return PageBaseLayout(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            title: Text(artist.name),
            leading: const SizedBox.shrink(),
            pinned: true,
            collapsedHeight: 60,
            expandedHeight: 200,
            // flexibleSpace: _CustomFlexibleSpace(album: album),
          ),
          SliverToBoxAdapter(
            child: FutureBuilder<ArtistInfo>(
              future: artistInfo,
              builder: (BuildContext context, AsyncSnapshot<ArtistInfo> snapshot){
                if(snapshot.hasData) {
                  final info = snapshot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if(info.popularTracks.isNotEmpty) ...[
                        Row(children: [
                          const Expanded(child: Text('Popular tracks')),
                          ElevatedButton(
                            onPressed: (){},
                            child: const Text('Show all')
                          )
                        ]),
                        TrackList(info.popularTracks, showAlbum: false, queueName: QueueNames.trackList)
                      ],

                      if(info.albums.isNotEmpty) ...[
                        Row(children: [
                          const Expanded(child: Text('Popular albums')),
                          ElevatedButton(
                            onPressed: (){},
                            child: const Text('Show all')
                          )
                        ]),
                        SizedBox(
                          height: 200,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: info.albums.map((album) => AlbumCard(album, 130)).toList(),
                          ),
                        )
                      ],

                      if(info.alsoAlbums.isNotEmpty) ...[
                        Row(children: [
                          const Expanded(child: Text('Compilations')),
                          ElevatedButton(
                              onPressed: (){},
                              child: const Text('Show all')
                          )
                        ]),
                        SizedBox(
                          height: 200,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: info.alsoAlbums.map((album) => AlbumCard(album, 130)).toList(),
                          ),
                        )
                      ],

                      if(info.similarArtists.isNotEmpty) ...[
                        const Text('Similar'),
                        SizedBox(
                          height: 210,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: info.similarArtists.map((album) => ArtistCard(album, 130)).toList(),
                          ),
                        )
                      ],

                      if(info.artist.links.isNotEmpty) ...[
                        const Text('Official pages'),
                        Wrap(
                          children: info.artist.links.map((link) => _SocialLink(link)).toList()
                        )
                      ],
                    ],
                  );
                }
                else {
                  return const CircularProgressIndicator();
                }
              }
            ),
          ),
        ],
      )
    );
  }
}

class _SocialLink extends StatelessWidget {
  final ArtistLink link;

  const _SocialLink(this.link);

  @override
  Widget build(BuildContext context) {
    Widget? icon;
    String? title;

    switch(link.type) {
      case 'official':
        icon = const Icon(Icons.language);
        title = link.title;
      case 'social':
        switch(link.socialNetwork!) {
          case 'youtube':
            icon = const FaIcon(FontAwesomeIcons.youtube);
            title = 'youtube';
          case 'twitter':
            icon = const FaIcon(FontAwesomeIcons.twitter);
            title = 'twitter';
        }
    }

    return OutlinedButton(
      onPressed: () async {
        await launchUrl(Uri.parse(link.href));
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if(icon != null) icon,
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(title ?? ''),
          )
        ],
      )
    );
  }
}
