import 'package:flutter/material.dart';

class PageBase extends StatelessWidget {
  final String? title;
  final List<Widget> slivers;
  final Widget? flexibleSpace;
  final _scrollController = ScrollController();
  final Function()? onDataPreload;

  PageBase({
    super.key,
    this.title,
    required this.slivers,
    this.onDataPreload,
    this.flexibleSpace
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
        // physics: CustomScrollPhysics(),
        slivers: [
          if(title != null)
            SliverPadding(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 25, bottom: 50),
              sliver: SliverToBoxAdapter(
                child: Text(title!, style: theme.textTheme.displayMedium)
              ),
            ),
          if(flexibleSpace != null)
            SliverPadding(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 25, bottom: 25),
              sliver: SliverAppBar(
                leading: const SizedBox.shrink(),
                pinned: true,
                flexibleSpace: flexibleSpace,
                toolbarHeight: 50,
                collapsedHeight: 64,
                expandedHeight: 200,
                backgroundColor: theme.colorScheme.surface,
                surfaceTintColor: Colors.transparent,
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
