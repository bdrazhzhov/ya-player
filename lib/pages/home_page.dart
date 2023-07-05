import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_state.dart';
import '../controls/account_area.dart';
import '../controls/play_controls.dart';
import '../controls/track_image.dart';
import '../controls/track_name.dart';
import '../models/music_api/track.dart';
import 'albums_page.dart';
import 'artists_page.dart';
import 'playlists_page.dart';
import 'stations_page.dart';
import 'tracks_page.dart';
import '../notifiers/progress_notifier.dart';
import '../services/service_locator.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final pageController = PageController();
  final sideMenu = SideMenuController();

  void _onItemTap(int index, SideMenuController sideMenuController) {
    sideMenuController.changePage(index);
    debugPrint('Page index: $index');
  }

  @override
  void initState() {
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
    getIt<AppState>().init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appState = getIt<AppState>();

    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SideMenu(
                  controller: sideMenu,
                  collapseWidth: 700,
                  style: SideMenuStyle(
                    openSideMenuWidth: 200,
                    itemHeight: 42.0,
                    selectedTitleTextStyle: theme.textTheme.headlineMedium,
                    unselectedTitleTextStyle: theme.textTheme.headlineMedium,
                    selectedIconColor: theme.iconTheme.color,
                    unselectedIconColor: theme.iconTheme.color,
                  ),
                  items: [
                    SideMenuItem(
                      priority: 0,
                      title: 'Stations',
                      onTap: _onItemTap,
                      icon: Icon(const FaIcon(FontAwesomeIcons.radio).icon),
                    ),
                    SideMenuItem(
                      priority: 1,
                      title: 'Tracks',
                      onTap: _onItemTap,
                      icon: Icon(const FaIcon(FontAwesomeIcons.compactDisc).icon),
                    ),
                    SideMenuItem(
                      priority: 2,
                      title: 'Albums',
                      onTap: _onItemTap,
                      icon: const Icon(Icons.list),
                    ),
                    SideMenuItem(
                      priority: 3,
                      title: 'Artists',
                      onTap: _onItemTap,
                      icon: const Icon(Icons.list),
                    ),
                    SideMenuItem(
                      priority: 4,
                      title: 'Playlists',
                      onTap: _onItemTap,
                      icon: const Icon(Icons.list),
                    ),
                  ],
                  footer: AccountArea(),
                ),
                Expanded(
                  child: PageView(
                    controller: pageController,
                    children: const [
                      StationsPage(),
                      TracksPage(),
                      AlbumsPage(),
                      ArtistsPage(),
                      PlaylistsPage()
                    ],
                  )
                )
              ],
            ),
          ),
          ValueListenableBuilder<ProgressBarState>(
            valueListenable: appState.progressNotifier,
            builder: (_, value, __) {
              return ProgressBar(
                progress: value.current,
                buffered: value.buffered,
                total: value.total,
                onSeek: appState.seek,
              );
            },
          ),
          Row(
            children: [
              PlayControls(appState: appState),
              TrackImage(appState: appState),
              TrackName(appState: appState),
              ValueListenableBuilder<Track?>(
                valueListenable: appState.trackNotifier,
                builder: (_, value, __) {
                  var iconData = Icons.favorite_border;
                  if(value != null && value.liked) {
                    iconData = Icons.favorite;
                  }
                  return IconButton(
                    icon: Icon(iconData),
                    onPressed: appState.likeCurrentTrack
                  );
                }
              ),
            ]
          )
        ],
      ),
    );
  }
}
