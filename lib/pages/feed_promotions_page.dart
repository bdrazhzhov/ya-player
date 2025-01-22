import 'package:flutter/material.dart';

import '/models/music_api/feed_promotions.dart';
import '/controls/album_card.dart';
import '/controls/page_loading_indicator.dart';
import '/helpers/custom_sliver_grid_delegate_extent.dart';
import '/music_api.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class FeedPromotionsPage extends StatelessWidget {
  final _musicApi = getIt<MusicApi>();
  final String id;
  late final Future<FeedPromotions> feedPromotions = _musicApi.feedPromotions(id);

  FeedPromotionsPage({super.key, required this.id});

  static const itemWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<FeedPromotions>(
        future: feedPromotions,
        builder: (_, AsyncSnapshot<FeedPromotions> snapshot){
          if(snapshot.hasData)
          {
            final feedPromotions = snapshot.data!;
            return PageBase(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.only(top: 20, bottom: 12),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      feedPromotions.title,
                      style: theme.textTheme.displayMedium,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(bottom: 20),
                  sliver: SliverToBoxAdapter(
                    child: Text(
                      feedPromotions.description,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ),
                SliverGrid.builder(
                  itemCount: feedPromotions.albums.length,
                  gridDelegate: CustomSliverGridDelegateExtent(
                      crossAxisSpacing: 12,
                      maxCrossAxisExtent: itemWidth,
                      height: itemWidth + 60
                  ),
                  itemBuilder: (_, index) => AlbumCard(feedPromotions.albums[index], itemWidth),
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
}
