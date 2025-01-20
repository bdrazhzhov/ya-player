import 'package:flutter/material.dart';

class PageBase extends StatelessWidget {
  final String? title;
  final List<Widget> slivers;
  final _scrollController = ScrollController();
  final Function()? onDataPreload;

  PageBase({
    super.key,
    this.title,
    required this.slivers,
    this.onDataPreload
  }) {
    _scrollController.addListener((){
      if(onDataPreload == null || _scrollController.position.outOfRange) return;
      if(_scrollController.offset <
          _scrollController.position.maxScrollExtent - 1000) {
        return;
      }

      onDataPreload!();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          if(title != null)
            SliverPadding(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 25, bottom: 50),
              sliver: SliverToBoxAdapter(
                child: Text(title!, style: theme.textTheme.displayMedium)
              ),
            ),
          ...slivers.map((sliver) => SliverPadding(
              padding: const EdgeInsets.only(left: 32, right: 32),
              sliver: sliver
            )
          )
        ]
      ),
    );
  }
}
