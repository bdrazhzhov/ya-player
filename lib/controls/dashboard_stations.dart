import 'dart:math';

import 'package:flutter/material.dart';

import '/services/app_state.dart';
import '/models/music_api/station.dart';
import '/services/service_locator.dart';
import 'station/station_card.dart';

class DashboardStations extends StatelessWidget {
  final _appState = getIt<AppState>();
  final double _maxSize = 240;
  final double _cardWidth = 180;
  final double _separatorWidth = 12;

  DashboardStations({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Station>>(
      valueListenable: _appState.stationsDashboardNotifier,
      builder: (_, stations, __) {
        return SliverToBoxAdapter(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double boxWidth = constraints.maxWidth;
              final maxWidth = stations.length * _cardWidth + _separatorWidth * (stations.length - 1);
              if(boxWidth > maxWidth) boxWidth = maxWidth;
              double listPadding = max(constraints.maxWidth - boxWidth - 1, 0) / 2;

              return SizedBox(
                height: _maxSize,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: listPadding),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: stations.length,
                    separatorBuilder: (_, __) => SizedBox(width: _separatorWidth),
                    itemBuilder: (BuildContext context, int index) {
                      final station = stations[index];

                      return StationCard(
                        station: station,
                        width: _cardWidth,
                      );
                    }
                  ),
                ),
              );
            },
          ),
        );
      }
    );
  }
}
