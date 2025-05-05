import 'package:flutter/material.dart';

import '/player/playback_queue.dart';
import '/player/player.dart';
import '/services/service_locator.dart';

class PageBase extends StatefulWidget {
  final String? title;
  final List<Widget> slivers;
  final Widget? flexibleSpace;
  final double? scrollItemHeight;
  final Future<dynamic>? onScrollPrepare;
  final Function()? onDataPreload;

  const PageBase({
    super.key,
    this.title,
    required this.slivers,
    this.flexibleSpace,
    this.scrollItemHeight,
    this.onScrollPrepare,
    this.onDataPreload,
  });

  @override
  State<PageBase> createState() => _PageBaseState();
}

class _PageBaseState extends State<PageBase> {
  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    initPageScrolling();
    initDataPreload();
  }

  @override
  void dispose() {
    getIt<Player>().trackLoadedEvent.removeHandler(trackLoadedHandler);
    super.dispose();
  }

  Future<void> trackLoadedHandler(track) async => scrollToCurrentTrack();

  Future<void> scrollToCurrentTrack() async {
    int index = getIt<PlaybackQueue>().currentIndex;
    if(index == -1) return;

    scrollController.jumpTo(index * widget.scrollItemHeight!);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          if(widget.title != null)
            SliverPadding(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 25, bottom: 50),
              sliver: SliverToBoxAdapter(
                child: Text(widget.title!, style: theme.textTheme.displayMedium),
              ),
            ),
          if(widget.flexibleSpace != null)
            SliverPadding(
              padding: const EdgeInsets.only(left: 32, right: 32, top: 25, bottom: 25),
              sliver: SliverAppBar(
                leading: const SizedBox.shrink(),
                pinned: true,
                flexibleSpace: widget.flexibleSpace,
                toolbarHeight: 50,
                collapsedHeight: 64,
                expandedHeight: 200,
                backgroundColor: theme.colorScheme.surface,
                surfaceTintColor: Colors.transparent,
              ),
            ),
          ...widget.slivers.map((sliver) => SliverPadding(
              padding: const EdgeInsets.only(left: 32, right: 32),
              sliver: sliver,
            )
          )
        ]
      ),
    );
  }

  void initDataPreload() {
    scrollController.addListener((){
      if(widget.onDataPreload == null || scrollController.position.outOfRange) return;
      if(scrollController.offset <
          scrollController.position.maxScrollExtent - 1000) {
        return;
      }

      widget.onDataPreload!();
    });
  }

  void initPageScrolling() {
    if(widget.scrollItemHeight == null) return;

    getIt<Player>().trackLoadedEvent.addHandler(trackLoadedHandler);

    if(widget.onScrollPrepare != null) {
      widget.onScrollPrepare!.then((_) => scrollToCurrentTrack());
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => scrollToCurrentTrack());
    }
  }
}
