import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import "package:collection/collection.dart";

import '../app_state.dart';
import '../music_api.dart';
import '../services/service_locator.dart';
import '../utils/color_extension.dart';
import '../models/music_api/dashboard.dart';
import '../models/music_api/station.dart';

class StationsPage extends StatefulWidget {
  const StationsPage({super.key});

  @override
  State<StationsPage> createState() => _StationsPageState();
}

class _StationsPageState extends State<StationsPage> {
  late final Future<StationsDashboard> dashboard;
  final appState = getIt<AppState>();
  Station? genre;

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

    return SingleChildScrollView(
      child: Column(
        children: [
          if(genre == null)
            ...[const Text('Stations'),
              ValueListenableBuilder<List<Station>>(
                  valueListenable: appState.stationsDashboardNotifier,
                  builder: (_, stations, __) {
                    return ValueListenableBuilder<Station?>(
                      valueListenable: appState.currentStationNotifier,
                      builder: (_, currentStation, __) {
                        return Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: stations.map(
                                  (station) => _StationCard(
                                  station: station,
                                  isCurrent: currentStation == station,
                                  width: width,
                              )
                          ).toList(),
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
                    widgets.add(
                      Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            groupName,
                            style: theme.textTheme.headlineSmall,
                          ),
                          Wrap(children: stations.map((station) {
                            return Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: GestureDetector(
                                onTap: (){ setState(() {
                                  genre = station;
                                }); },
                                child: _StationGenreCard(station)
                              ),
                            );
                          }).toList())
                        ],
                      )
                    );
                  });

                  return Column(children: widgets);
                }
              ),
            ]
          else
            ...[
              Text(genre!.name, style: theme.textTheme.headlineLarge,),
              Wrap(children: genre!.subStations.map((station) {
                return Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: _StationGenreCard(station),
                );
              }).toList())
            ]
        ],
      ),
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
      onTap: () { appState.selectStation(station); },
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

class _StationGenreCard extends StatelessWidget {
  final Station station;

  const _StationGenreCard(this.station);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: station.icon.backgroundColor.toColor(),
              shape: BoxShape.circle
            ),
            child: Center(
              child: CachedNetworkImage(
                width: 30,
                height: 30,
                fit: BoxFit.fitWidth,
                imageUrl: MusicApi.imageUrl(station.icon.imageUrl, '100x100').toString(),
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 240),
              child: Text(station.name + (station.subStations.isNotEmpty ? ' *' : ''),
                style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
        ],
      ),
    );
  }
}
