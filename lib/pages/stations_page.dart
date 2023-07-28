import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../controls/page_base_layout.dart';
import '../app_state.dart';
import '../helpers/nav_keys.dart';
import '../music_api.dart';
import '../services/service_locator.dart';
import '../helpers/color_extension.dart';
import '../models/music_api/dashboard.dart';
import '../models/music_api/station.dart';
import 'genre_page.dart';
import '../controls/station_genre.dart';

class StationsPage extends StatelessWidget {
  final GlobalKey<NavigatorState> _navKey = GlobalKey();

  StationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navKey,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings){
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => const _StationsWidget()
        );
      },
    );
  }
}

class _StationsWidget extends StatefulWidget {
  const _StationsWidget();

  @override
  State<_StationsWidget> createState() => _StationsWidgetState();
}

class _StationsWidgetState extends State<_StationsWidget> {
  late final Future<StationsDashboard> dashboard;
  final appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    var width = size.width / 3;
    if(width < 130) {
      width = 130;
    } else if(width > 200) {
      width = 200;
    }

    final i10n = AppLocalizations.of(context);
    final genreNames = {
      'genre': i10n?.genre,
      'mood': i10n?.mood,
      'activity': i10n?.activity,
      'epoch': i10n?.epoch,
      'personal': i10n?.personal,
      'editorial': i10n?.editorial
    };

    return PageBaseLayout(
      title: 'Stations',
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 68),
              child: Text('Stations', style: theme.textTheme.headlineLarge,),
            ),
            ValueListenableBuilder<List<Station>>(
              valueListenable: appState.stationsDashboardNotifier,
              builder: (_, stations, __) {
                return ValueListenableBuilder<Station?>(
                  valueListenable: appState.currentStationNotifier,
                  builder: (_, currentStation, __) {
                    return Center(
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: stations.map(
                            (station) => _StationCard(
                            station: station,
                            isCurrent: currentStation == station,
                            width: width,
                          )
                        ).toList(),
                      ),
                    );
                  }
                );
              }
            ),
            ValueListenableBuilder<Map<String,List<Station>>>(
              valueListenable: appState.stationsNotifier,
              builder: (_, groups, __) {
                List<Widget> widgets = [];

                groups.forEach((String groupName, List<Station> stations) {
                  widgets.addAll(
                    [
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            genreNames[groupName] ?? '',
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                      ),
                      StationsList(stations: stations)
                    ],
                  );
                });

                return Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: widgets
                  ),
                );
              }
            ),
          ],
        ),
      ),
    );
  }
}

class StationsList extends StatelessWidget {
  final List<Station> stations;
  final appState = getIt<AppState>();

  static const double _minWidth = 250;
  static const double _maxWidth = 412;

  StationsList({super.key, required this.stations});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        int columnsNumber = 3;
        double width = constraints.maxWidth / columnsNumber;

        while(true) {
          if(width < _minWidth) columnsNumber -= 1;
          if(columnsNumber == 0) {
            columnsNumber = 1;
            width = constraints.maxWidth;
            break;
          }
          if(width > _maxWidth) columnsNumber += 1;

          width = constraints.maxWidth / columnsNumber;

          if(columnsNumber == 1 || width >= _minWidth && width <= _maxWidth) break;
        }

        return Wrap(children: stations.map((station) {
          return Container(
            constraints: BoxConstraints(maxWidth: width),
            padding: const EdgeInsets.all(4.0),
            child: GestureDetector(
                onTap: () async {
                  if(station.subStations.isNotEmpty){
                    await NavKeys.mainNav.currentState!.push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => GenrePage(genre: station),
                        reverseTransitionDuration: Duration.zero,
                      )
                    );
                  }
                  else {
                    appState.playStationTracks(station);
                  }
                },
                child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: StationGenre(station)
                )
            ),
          );
        }).toList());
      }
    );
  }
}

class _StationCard extends StatelessWidget {
  final Station station;
  final bool isCurrent;
  final double width;

  _StationCard({
    required this.station,
    required this.isCurrent,
    required this.width,
  });

  final appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final outlineColor = isCurrent ? theme.colorScheme.outline : Colors.transparent;

    return InkResponse(
      onTap: () { appState.playStationTracks(station); },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(width: 3, color: outlineColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              width: width,
              height: width,
              decoration: BoxDecoration(
                  color: station.icon.backgroundColor.toColor(),
                  shape: BoxShape.circle
              ),
              child: Center(
                child: CachedNetworkImage(
                  width: width / 1.5,
                  height: width / 1.5,
                  fit: BoxFit.fitWidth,
                  imageUrl: MusicApi.imageUrl(station.icon.imageUrl, '300x300').toString(),
                  placeholder: (context, url) => const CircularProgressIndicator(),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 24),
              child: Text(station.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}
