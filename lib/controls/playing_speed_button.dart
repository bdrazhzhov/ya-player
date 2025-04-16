import 'package:flutter/material.dart';

import '/player_state.dart';
import '/services/service_locator.dart';

class PlayingSpeedButton extends StatelessWidget {
  final _playerState = getIt<PlayerState>();
  final _overlayController = OverlayPortalController();
  
  PlayingSpeedButton({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OverlayPortal(
      controller: _overlayController,
      overlayChildBuilder: (BuildContext context) {
        return Positioned(
          bottom: 60,
          right: 12,
          child: TapRegion(
            consumeOutsideTaps: true,
            onTapOutside: (_) => _overlayController.hide(),
            child: SizedBox(
              width: 380,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  border: Border.all(color: theme.focusColor),
                  borderRadius: BorderRadius.all(Radius.circular(4))
                ),
                child: Center(
                  child: ValueListenableBuilder(
                    valueListenable: _playerState.rateNotifier,
                    builder: (_, double speed, __) {
                      return SegmentedButton<double>(
                        segments: <double>[0.75, 1, 1.25, 1.5, 1.75, 2].map((i) => ButtonSegment(
                          value: i,
                          label: Center(child: Text('${i}x')),
                        )).toList(),
                        selected: {speed},
                        showSelectedIcon: false,
                        onSelectionChanged: (Set<double> value) {
                          _playerState.rateNotifier.value = value.single;
                        },
                      );
                    },
                  ),
                ),
              ),
            ),
          )
        );
      },
      child: TextButton(
        onPressed: () => _overlayController.show(),
        child: ValueListenableBuilder(
          valueListenable: _playerState.rateNotifier,
          builder: (_, double value, __) {
            return Text('${value}x');
          },
        )
      ),
    );
  }
}
