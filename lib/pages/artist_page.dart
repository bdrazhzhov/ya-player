import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '/controls/artist/artist_flexible_space.dart';
import '/controls/artist/artist_social_link.dart';
import '/controls/artist/artist_section_header.dart';
import '/app_state.dart';
import '/controls/custom_separated_hlist.dart';
import '/controls/page_loading_indicator.dart';
import '/controls/sliver_track_list.dart';
import 'artist_albums_page.dart';
import 'artist_compilations_page.dart';
import 'artist_tracks_page.dart';
import 'page_base.dart';
import '/controls/album_card.dart';
import '/controls/artist_card.dart';
import '/models/music_api/artist.dart';
import '/models/music_api/artist_info.dart';
import '/services/service_locator.dart';
import '/music_api.dart';

class ArtistPage extends StatelessWidget {
  late final Future<ArtistInfo> artistInfo = _musicApi.artistInfo(artist.id);
  final _appState = getIt<AppState>();
  final _musicApi = getIt<MusicApi>();
  final Artist artist;

  ArtistPage(this.artist, {super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<ArtistInfo>(
      future: artistInfo,
      builder: (BuildContext context, AsyncSnapshot<ArtistInfo> snapshot){
        if(snapshot.hasData)
        {
          final info = snapshot.data!;
          return PageBase(
            slivers: [
              SliverAppBar(
                leading: const SizedBox.shrink(),
                pinned: true,
                flexibleSpace: ArtistFlexibleSpace(artistInfo: info),
                collapsedHeight: 60,
                expandedHeight: 200,
              ),

              if(info.popularTracks.isNotEmpty) ...[
                ArtistSectionHeader(
                  title: l10n.artist_popularTracks,
                  onPressed: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (_, __, ___) =>
                          ArtistTracksPage(artist: info.artist),
                      reverseTransitionDuration: Duration.zero,
                    ));
                  }
                ),
                SliverTrackList(
                  tracks: info.popularTracks,
                  onBeforeStartPlaying: (int? index) =>
                      _appState.playContent(info, info.popularTracks, index)
                ),
              ],

              if(info.albums.isNotEmpty) ...[
                ArtistSectionHeader(
                  title: l10n.artist_popularAlbums,
                  onPressed: (){
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ArtistAlbumsPage(artist: info.artist),
                      reverseTransitionDuration: Duration.zero,
                    ));
                  }
                ),
                createSeparatedList(info.albums.map((album) => AlbumCard(album, 150))),
              ],

              if(info.alsoAlbums.isNotEmpty) ...[
                ArtistSectionHeader(
                  title: l10n.artist_compilations,
                  onPressed: (){
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (_, __, ___) => ArtistCompilationsPage(artist: info.artist),
                      reverseTransitionDuration: Duration.zero,
                    ));
                  }
                ),
                createSeparatedList(info.alsoAlbums.map((album) => AlbumCard(album, 150))),
              ],

              if(info.similarArtists.isNotEmpty) ...[
                ArtistSectionHeader(title: l10n.artist_similar),
                createSeparatedList(info.similarArtists.map((artist) => ArtistCard(artist, 150))),
              ],

              if(info.artist.links.isNotEmpty) ...[
                ArtistSectionHeader(title: l10n.artist_official),
                SliverToBoxAdapter(
                  child: Wrap(
                      children: info.artist.links.map((link) => ArtistSocialLink(link)).toList()
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





