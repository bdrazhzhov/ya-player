import 'package:flutter/material.dart';

import '/controls/page_loading_indicator.dart';
import '/models/music_api_types.dart';
import '/music_api.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class MetaTagsPage extends StatelessWidget {
  final String tag;
  final _musicApi = getIt<MusicApi>();
  late final _metatagsFuture = _musicApi.metaTags(tag);

  MetaTagsPage({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder(
      future: _metatagsFuture,
      builder: (_, AsyncSnapshot<MetaTags> snapshot) {
        if(snapshot.hasData)
        {
          final metatags = snapshot.data!;

          return PageBase(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.only(top: 20, bottom: 12),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    metatags.title.fullTitle,
                    style: theme.textTheme.displayMedium,
                  ),
                ),
              ),

            ],
          );
        }

        return const PageLoadingIndicator();
      },
    );
  }
}
