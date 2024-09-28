import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controls/custom_separated_hlist.dart';
import '../controls/page_loading_indicator.dart';
import 'page_base.dart';
import '../controls/album_card.dart';
import '../controls/artist_card.dart';
import '../controls/sliver_track_list.dart';
import '../helpers/playback_queue.dart';
import '../models/music_api/artist.dart';
import '../models/music_api/artist_info.dart';
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
    return FutureBuilder<ArtistInfo>(
      future: artistInfo,
      builder: (BuildContext context, AsyncSnapshot<ArtistInfo> snapshot){
        if(snapshot.hasData)
        {
          final info = snapshot.data!;
          return PageBase(
            title: artist.name,
            slivers: [
              // SliverAppBar(
              //   title: Text(artist.name),
              //   leading: const SizedBox.shrink(),
              //   pinned: true,
              //   collapsedHeight: 60,
              //   expandedHeight: 200,
              // ),

              if(info.popularTracks.isNotEmpty) ...[
                const SectionHeader(title: 'Popular tracks'),
                SliverTrackList(tracks: info.popularTracks, showAlbum: false, queueName: QueueNames.artistPopularTracks),
              ],

              if(info.albums.isNotEmpty) ...[
                const SectionHeader(title: 'Popular albums'),
                createSeparatedList(info.albums.map((album) => AlbumCard(album, 130))),
              ],

              if(info.alsoAlbums.isNotEmpty) ...[
                const SectionHeader(title: 'Compilations'),
                createSeparatedList(info.alsoAlbums.map((album) => AlbumCard(album, 130))),
              ],

              if(info.similarArtists.isNotEmpty) ...[
                const SectionHeader(title: 'Similar'),
                createSeparatedList(info.similarArtists.map((artist) => ArtistCard(artist, 130))),
              ],

              if(info.artist.links.isNotEmpty) ...[
                const SectionHeader(title: 'Official pages'),
                SliverToBoxAdapter(
                  child: Wrap(
                      children: info.artist.links.map((link) => _SocialLink(link)).toList()
                  ),
                )
              ],
            ],
          );
        }
        else
        {
          return const PageLoadingIndicator();
        }
      }
    );
  }

  SliverToBoxAdapter createSeparatedList(Iterable<Widget> items) {
    return SliverToBoxAdapter(
      child: CustomSeparatedHList(
        children: items,
        separatorWidget: const SizedBox(width: 20),
      ),
    );
  }
}


class SectionHeader extends StatelessWidget {
  final String title;
  final void Function()? onPressed;

  const SectionHeader({
    super.key,
    required this.title,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.only(top: 20, bottom: 12),
      sliver: SliverToBoxAdapter(
        child: Row(children: [
          Expanded(child: Text(title, style: Theme.of(context).textTheme.titleLarge,)),
          if(onPressed != null) ...[
            ElevatedButton(
              onPressed: onPressed,
              child: const Text('Show all')
            )
          ]
        ]),
      ),
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
