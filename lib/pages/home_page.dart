import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../app_state.dart';
import '../controls/account_area.dart';
import '../controls/play_controls.dart';
import '../controls/track_image.dart';
import '../controls/track_name.dart';
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
  final _appState = getIt<AppState>();
  int _currentPageIndex = 0;

  void _onItemTap(int index, SideMenuController sideMenuController) {
    sideMenuController.changePage(index);
    debugPrint('Page index: $index');
  }

  @override
  void initState() {
    sideMenu.addListener((index) {
      pageController.jumpToPage(index);
    });
    _appState.init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget? navBar;
    if(defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS) {
      navBar = NavigationBar(
        height: 50,
        selectedIndex: _currentPageIndex,
        onDestinationSelected: (int index) {
          pageController.jumpToPage(index);
          setState(() {
            _currentPageIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.radio_outlined),
            label: 'Stations',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Tracks',
          ),
          NavigationDestination(
            icon: Icon(Icons.album_outlined),
            label: 'Albums',
          ),
          NavigationDestination(
            icon: Icon(Icons.mic),
            label: 'Artists',
          ),
        ],
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                if(defaultTargetPlatform != TargetPlatform.android &&
                    defaultTargetPlatform != TargetPlatform.iOS)
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
                          icon: const Icon(Icons.radio_outlined),
                        ),
                        SideMenuItem(
                          priority: 1,
                          title: 'Tracks',
                          onTap: _onItemTap,
                          icon: const Icon(Icons.list),
                        ),
                        SideMenuItem(
                          priority: 2,
                          title: 'Albums',
                          onTap: _onItemTap,
                          icon: const Icon(Icons.album),
                        ),
                        SideMenuItem(
                          priority: 3,
                          title: 'Artists',
                          onTap: _onItemTap,
                          icon: const Icon(Icons.mic),
                        ),
                        SideMenuItem(
                          priority: 4,
                          title: 'Playlists',
                          onTap: _onItemTap,
                          icon: const Icon(Icons.queue_music),
                        ),
                      ],
                      footer: AccountArea(),
                    ),
                Expanded(
                  child: PageView(
                    controller: pageController,
                    children: [
                      const StationsPage(),
                      const TracksPage(),
                      const AlbumsPage(),
                      const ArtistsPage(),
                      const PlaylistsPage(),
                      AccountArea()
                    ],
                  )
                )
              ],
            ),
          ) ,
          ValueListenableBuilder<ProgressBarState>(
            valueListenable: _appState.progressNotifier,
            builder: (_, value, __) {
              return ProgressBar(
                progress: value.current,
                buffered: value.buffered,
                total: value.total,
                onSeek: _appState.seek,
              );
            },
          ),
          Row(
            children: [
              PlayControls(appState: _appState),
              TrackImage(appState: _appState),
              TrackName(appState: _appState),
              ValueListenableBuilder<bool>(
                valueListenable: _appState.trackLikeNotifier,
                builder: (_, value, __) {
                  var iconData = value ? Icons.favorite : Icons.favorite_border;
                  return IconButton(
                    icon: Icon(iconData),
                    onPressed: _appState.likeCurrentTrack
                  );
                }
              ),
              const Expanded(child: SizedBox(),),
              if(defaultTargetPlatform == TargetPlatform.windows ||
                  defaultTargetPlatform == TargetPlatform.linux ||
                  defaultTargetPlatform == TargetPlatform.macOS) Slider(
                // value: _volume,
                value: _appState.volume,
                onChanged: (double value) {
                  setState((){
                    _appState.volume = value;
                    // _volume = value;
                  });
                },
              )
              else
                IconButton(
                  onPressed: (){
                    pageController.jumpToPage(5);
                  },
                  icon: const Icon(Icons.account_box)
                )
            ]
          ),
        ],
      ),
      bottomNavigationBar: navBar,
    );
  }
}
