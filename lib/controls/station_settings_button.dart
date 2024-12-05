import 'package:flutter/material.dart';

import '/models/music_api/station.dart';
import 'station_settings_widget.dart';

class StationSettingsButton extends StatelessWidget {
  final _overlayController = OverlayPortalController();
  final Station station;

  StationSettingsButton({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (BuildContext context) {
        return Positioned(
          bottom: 60,
          left: 40,
          child: TapRegion(
            consumeOutsideTaps: true,
            onTapOutside: (_) => _overlayController.hide(),
            child: SizedBox(
              width: 500,
              height: 300,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  border: Border.all(color: theme.focusColor),
                  borderRadius: BorderRadius.all(Radius.circular(12))
                ),
                child: StationSettingsWidget(station: station),
              ),
            ),
          )
        );
      },
      child: IconButton(
        iconSize: 26,
        icon: const Icon(Icons.tune_outlined),
        onPressed: () => _overlayController.show(),
      ),
    );
  }
}
