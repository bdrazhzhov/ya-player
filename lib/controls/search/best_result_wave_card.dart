import 'package:flutter/material.dart';

import '/models/music_api/radio_session.dart';
import '/models/music_api/search.dart';
import '/player/player.dart';
import '/services/app_state.dart';
import '/services/service_locator.dart';
import 'best_result_wave_cover.dart';

class BestResultWaveCard extends StatefulWidget {
  final BestResultWave bestResult;

  const BestResultWaveCard(this.bestResult, {super.key});

  @override
  State<BestResultWaveCard> createState() => _BestResultWaveCardState();
}

class _BestResultWaveCardState extends State<BestResultWaveCard> {
  final appState = getIt<AppState>();
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            spacing: 12,
            children: [
              BestResultWaveCover(bestResult: widget.bestResult, isHovered: isHovered),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(widget.bestResult.title),
                    Text(
                      widget.bestResult.header,
                      style: TextStyle(color: theme.colorScheme.outline),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        onEnter: (_) {
          isHovered = true;
          setState(() {});
        },
        onExit: (_) {
          isHovered = false;
          setState(() {});
        },
      ),
      onTap: () {
        final playContext = appState.playContext;
        if (playContext is RadioSession &&
            playContext.wave.stationId == widget.bestResult.stationId.toString()) {
          getIt<Player>().playPause();
          return;
        }
        appState.playObjectStation(widget.bestResult.stationId);
      },
    );
  }
}
