import 'package:flutter/material.dart';

import '/controls/album_card.dart';
import '/controls/artist/artist_flexible_space.dart';
import '/controls/artist/artist_social_link.dart';
import '/controls/artist_card.dart';
import '/controls/horizontal_list_with_title.dart';
import '/controls/page_loading_indicator.dart';
import '/controls/page_section_header.dart';
import '/controls/sliver_track_list.dart';
import '/l10n/app_localizations.dart';
import '/models/music_api/artist_info.dart';
import '/services/music_api.dart';
import '/services/service_locator.dart';
import 'artist_albums_page.dart';
import 'artist_compilations_page.dart';
import 'artist_tracks_page.dart';
import 'page_base.dart';

class ArtistPage extends StatelessWidget {
  late final Future<ArtistInfo> artistInfo = _musicApi.artistInfo(artistId);
  final _musicApi = getIt<MusicApi>();
  final String artistId;

  ArtistPage({super.key, required this.artistId});

  static const double _cardWidth = 150;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<ArtistInfo>(
        future: artistInfo,
        builder: (BuildContext context, AsyncSnapshot<ArtistInfo> snapshot) {
          if (snapshot.hasData) {
            final info = snapshot.data!;
            return PageBase(
              flexibleSpace: ArtistFlexibleSpace(artistInfo: info),
              slivers: [
                if (info.popularTracks.isNotEmpty) ...[
                  toSliverWithPadding(
                    child: PageSectionHeader(
                      title: l10n.artist_popularTracks,
                      onPressed: () {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (_, __, ___) => ArtistTracksPage(artist: info.artist),
                          reverseTransitionDuration: Duration.zero,
                        ));
                      },
                    ),
                    bottom: 20,
                  ),
                  SliverTrackList(
                    playContext: info.artist,
                    tracks: info.popularTracks,
                  ),
                ],
                if (info.albums.isNotEmpty) ...[
                  createSeparatedList(
                    items: info.albums.map((album) => AlbumCard(album, _cardWidth)),
                    title: l10n.artist_popularAlbums,
                    onHeaderTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ArtistAlbumsPage(artist: info.artist),
                        reverseTransitionDuration: Duration.zero,
                      ));
                    },
                  ),
                ],
                if (info.alsoAlbums.isNotEmpty) ...[
                  createSeparatedList(
                    items: info.alsoAlbums.map((album) => AlbumCard(album, _cardWidth)),
                    title: l10n.artist_compilations,
                    onHeaderTap: () {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (_, __, ___) => ArtistCompilationsPage(artist: info.artist),
                        reverseTransitionDuration: Duration.zero,
                      ));
                    },
                  ),
                ],
                if (info.similarArtists.isNotEmpty) ...[
                  createSeparatedList(
                    items: info.similarArtists.map((artist) => ArtistCard(artist, _cardWidth)),
                    title: l10n.artist_similar,
                  ),
                ],
                if (info.artist.links.isNotEmpty) ...[
                  toSliverWithPadding(
                    child: PageSectionHeader(title: l10n.artist_official),
                    top: 20,
                    bottom: 12,
                  ),
                  SliverToBoxAdapter(
                    child: Wrap(
                      children: info.artist.links.map((link) => ArtistSocialLink(link)).toList(),
                    ),
                  )
                ],
              ],
            );
          } else {
            return const PageLoadingIndicator();
          }
        });
  }

  Widget createSeparatedList({
    required Iterable<Widget> items,
    required String title,
    void Function()? onHeaderTap,
    double? itemWidth,
  }) {
    return toSliverWithPadding(
      child: HorizontalListWithTitle(
        title: PageSectionHeader(title: title, onPressed: onHeaderTap),
        spacing: 20,
        itemWidth: itemWidth ?? _cardWidth,
        children: items,
      ),
      top: 20,
    );
  }

  Widget toSliverWithPadding({required Widget child, double? top, double? bottom}) {
    return SliverPadding(
      sliver: SliverToBoxAdapter(child: child),
      padding: EdgeInsetsGeometry.only(top: top ?? 0, bottom: bottom ?? 0),
    );
  }
}
