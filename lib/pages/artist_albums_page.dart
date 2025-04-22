import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/controls/album_card.dart';
import '/helpers/custom_sliver_grid_delegate_extent.dart';
import '/models/music_api/artist.dart';
import '/models/music_api/paged_data.dart';
import '/models/music_api/album.dart';
import '/services/music_api.dart';
import '/services/service_locator.dart';
import '/controls/page_loading_indicator.dart';
import 'page_base.dart';

class ArtistAlbumsPage extends StatefulWidget {
  final Artist artist;

  const ArtistAlbumsPage({super.key, required this.artist});

  @override
  State<ArtistAlbumsPage> createState() => _ArtistAlbumsPageState();
}

class _ArtistAlbumsPageState extends State<ArtistAlbumsPage> {
  final musicApi = getIt<MusicApi>();
  late Future<List<Album>> albumsFuture = _loadData();
  AlbumsSortBy sortBy = AlbumsSortBy.rating;
  AlbumsSortOrder sortOrder = AlbumsSortOrder.desc;
  final selectedStyle = TextStyle(fontWeight: FontWeight.bold);

  static const itemWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<List<Album>>(
      future: albumsFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Album>> snapshot){
        if(snapshot.hasData)
        {
          final albums = snapshot.data!;
          return PageBase(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 20, bottom: 12),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          widget.artist.name,
                          style: theme.textTheme.displayLarge,
                        ),
                      ),
                      buildPopupMenu(context)
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 20),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    l10n.artist_allAlbums,
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
              ),
              SliverGrid.builder(
                itemCount: albums.length,
                gridDelegate: CustomSliverGridDelegateExtent(
                  crossAxisSpacing: 12,
                  maxCrossAxisExtent: itemWidth,
                  height: itemWidth + 60
                ),
                itemBuilder: (_, index) => AlbumCard(albums[index], itemWidth),
              )
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

  PopupMenuButton<Object> buildPopupMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopupMenuButton<Object>(
      icon: Icon(Icons.sort),
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      popUpAnimationStyle: AnimationStyle.noAnimation,
      offset: Offset(0, 40),
      itemBuilder: (BuildContext context) => [
        buildMenuItem(l10n.artist_albumsSortByRating, AlbumsSortBy.rating, sortBy),
        buildMenuItem(l10n.artist_albumsSortByYear, AlbumsSortBy.year, sortBy),
        PopupMenuDivider(),
        buildMenuItem(l10n.artist_albumsSortOrderAsc, AlbumsSortOrder.asc, sortOrder),
        buildMenuItem(l10n.artist_albumsSortOrderDesc, AlbumsSortOrder.desc, sortOrder),
      ],
      onSelected: (value){
        if(value is AlbumsSortBy)
        {
          sortBy = value;
        }
        else if(value is AlbumsSortOrder)
        {
          sortOrder = value;
        }
        albumsFuture = _loadData();
        setState(() {});
      },
    );
  }

  PopupMenuItem<Object> buildMenuItem(String text, Object value, Object compareTo) {
    return PopupMenuItem(
      value: value,
      height: 40,
      child: Text(
        text,
        style: value == compareTo ? selectedStyle : null
      ),
    );
  }

  Future<List<Album>> _loadData() async {
    final List<Album> albums = [];
    late PagedData<Album> data;
    int page = 0;

    do {
      data = await musicApi.artistAlbums(
        artistId: widget.artist.id,
        page: page,
        sortBy: sortBy,
        sortOrder: sortOrder
      );
      albums.addAll(data.items);
      page += 1;
    } while(data.total > albums.length);

    return albums;
  }
}
