import 'package:flutter/material.dart';
import 'package:ya_player/pages/meta_tags_page.dart';

import '/models/music_api/meta_tags.dart';
import '/app_state.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class GenresTreePage extends StatelessWidget {
  final _appState = getIt<AppState>();
  final String id;

  GenresTreePage({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Tree? tree = _appState.getTree(id);

    if(tree == null) {
      return const Text('No data');
    }

    return PageBase(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 20, bottom: 12),
          sliver: SliverToBoxAdapter(
            child: Text(
              tree.title,
              style: theme.textTheme.displayMedium,
            ),
          ),
        ),
        SliverList.list(children: _getGenres(tree.leaves, context))
      ],
    );
  }

  List<Widget> _getGenres(List<Leaf> leaves, BuildContext context) {
    final theme = Theme.of(context);
    List<Widget> genres = [];

    addGenre(Leaf leaf) {
      final text = Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            child: Text(
              leaf.title,
              style: theme.textTheme.bodyLarge,
            ),
            onTap: () {
              Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => MetaTagsPage(tag: leaf.tag),
                    reverseTransitionDuration: Duration.zero,
                  )
              );
            }
          ),
        ),
      );
      genres.add(text);
    }

    for(Leaf leaf in leaves) {
      final text = Padding(
        padding: const EdgeInsets.only(top: 34, bottom: 12),
        child: Text(
          leaf.title,
          style: theme.textTheme.titleLarge,
        ),
      );
      genres.add(text);

      addGenre(leaf);

      if(leaf.leaves.isEmpty) continue;

      for(Leaf leaf in leaf.leaves) {
        addGenre(leaf);
      }
    }

    return genres;
  }
}
