import 'package:flutter/material.dart';

import '/app_state.dart';
import '/services/service_locator.dart';
import 'station_restriction_widget.dart';
import '/models/music_api/station.dart';

class StationSettingsWidget extends StatelessWidget {
  final Station station;
  final _appState = getIt<AppState>();

  StationSettingsWidget({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    List<StationOptionWidget> restrictions = [];

    station.restrictions2.forEach((key,restrictions2){
      if(restrictions2.possibleValues.isEmpty) return;

      restrictions.add(StationOptionWidget(
        restrictions: restrictions2,
        value: station.settings2[key],
        onChange: (String value) => _settingsChanged(key, value),
      ));
    });

    final theme = Theme.of(context);

    return Column(
      children: [
        SizedBox(height: 20),
        Text(station.name, style: theme.textTheme.titleLarge),
        ...restrictions
      ],
    );
  }

  void _settingsChanged(String key, String value) async {
    station.settings2[key] = value;
    _appState.stationSettingsNotifier.value = Map.from(station.settings2);
  }
}
