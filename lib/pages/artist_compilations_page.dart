import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '../controls/album_card.dart';
import '../controls/page_loading_indicator.dart';
import '../helpers/custom_sliver_grid_delegate_extent.dart';
import '../helpers/paged_data.dart';
import '../models/music_api/album.dart';
import '../models/music_api/artist.dart';
import '../music_api.dart';
import '../services/service_locator.dart';
import 'page_base.dart';

class ArtistCompilationsPage extends StatefulWidget {
  final Artist artist;

  const ArtistCompilationsPage({super.key, required this.artist});

  @override
  State<ArtistCompilationsPage> createState() => _ArtistCompilationsPageState();
}

class _ArtistCompilationsPageState extends State<ArtistCompilationsPage> {
  final musicApi = getIt<MusicApi>();
  final List<Album> albums = [];
  bool isFirstLoading = true;
  bool isEverythingLoaded = false;
  int page = 0;
  bool isDataPreloading = false;

  static const itemWidth = 200.0;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    if(isFirstLoading) return const PageLoadingIndicator();

    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return PageBase(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 20, bottom: 12),
          sliver: SliverToBoxAdapter(
            child: Text(
              widget.artist.name,
              style: theme.textTheme.displayLarge,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 20),
          sliver: SliverToBoxAdapter(
            child: Text(
              l10n.artist_allCompilations,
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
      onDataPreload: loadData,
    );
  }

  Future<void> loadData() async {
    if(isEverythingLoaded) return;
    if(isDataPreloading) return;
    isDataPreloading = true;

    final PagedData<Album> data = await musicApi.artistAlsoAlbums(
      artistId: widget.artist.id,
      page: page
    );

    isEverythingLoaded = data.total == albums.length;
    if(!isEverythingLoaded) {
      page += 1;
      isFirstLoading = false;
    }

    albums.addAll(data.items);

    isDataPreloading = false;

    setState(() {});
  }
}
