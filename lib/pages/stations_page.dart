import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
  late final MusicApi musicApi;
  late final AppState appState;

  _StationsPageState() {
    appState = getIt<AppState>();
    musicApi = getIt<MusicApi>();
    dashboard = musicApi.stationsDashboard();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text('Stations'),
          FutureBuilder<StationsDashboard>(
            future: dashboard,
            builder: (context, snapshot){
              if(snapshot.hasData) {
                final List<Station> stations = snapshot.data!.stations;
                return ValueListenableBuilder<Station?>(
                  valueListenable: appState.currentStationNotifier,
                  builder: (_, currentStation, __) {
                    return Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: stations.map(
                              (station) => _StationCard(
                                  station: station,
                                  isCurrent: currentStation == station
                                )
                      ).toList(),
                    );
                  }
                );
              }
              else {
                return const Text('No stations');
              }
            }
          )
        ],
      ),
    );
  }
}

class _StationCard extends StatelessWidget {
  _StationCard({
    required this.station,
    required this.isCurrent,
  });

  final Station station;
  final bool isCurrent;
  final appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    BoxDecoration? decoration;

    if(isCurrent) {
      decoration = BoxDecoration(
        border: Border.all(width: 3, color: Colors.black12),
        borderRadius: BorderRadius.circular(8),
      );
    }

    return InkResponse(
      onTap: () { appState.selectStation(station); },
      child: Container(
        decoration: decoration,
        child: Column(
          children: [
            Container(
              width: 208,
              height: 208,
              decoration: BoxDecoration(
                  color: station.icon.backgroundColor.toColor(),
                  shape: BoxShape.circle
              ),
              child: CachedNetworkImage(
                width: 150,
                height: 150,
                imageUrl: MusicApi.imageUrl(station.icon.imageUrl, '150x150').toString(),
                placeholder: (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
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
