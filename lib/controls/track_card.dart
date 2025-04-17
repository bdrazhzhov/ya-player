import 'package:flutter/material.dart';

import '../app_state.dart';
import '../player/players_manager.dart';
import '../player_state.dart';
import '../services/service_locator.dart';
import '/l10n/app_localizations.dart';
import '/models/music_api/track.dart';
import 'play_pause_button.dart';
import 'track_list/track_animation_cover.dart';
import 'yandex_image.dart';

class TrackCard extends StatelessWidget {
  final Track track;
  final double width;
  final bool isPlaying = false;
  final bool isCurrent = false;

  TrackCard({super.key, required this.track, required this.width});

  final _appState = getIt<AppState>();
  final _playerState = getIt<PlayerState>();
  final _player = getIt<PlayersManager>();
  final _hoverNotifier = ValueNotifier<bool>(false);

  static const double hoverButtonSize = 50;
  static const buttonColor = Color.fromARGB(255, 255, 219, 77);
  static const double coverCornersRadius = 4.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return InkResponse(
      onTap: () {
        bool isCurrent = _playerState.trackNotifier.value == track;

        if (!isCurrent) {
          _appState.playTrack(track);
          return;
        }

        _player.playPause();
      },
      onHover: (value){
        _hoverNotifier.value = value;
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              YandexImage(
                uriTemplate: track.ogImage,
                size: width,
                borderRadius: 8,
              ),
              Positioned(
                left: 8,
                top: 8,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: Text(
                      l10n.track_card_track,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: theme.textTheme.labelMedium?.fontSize,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: ValueListenableBuilder(
                  valueListenable: _hoverNotifier,
                  builder: (BuildContext context, bool value, Widget? child) {
                    if(!value) {
                      return Center(child: _buildAnimatedCover());
                    }

                    return AnimatedOpacity(
                      opacity: value ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: child,
                    );
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(150),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: PlayPauseButton(
                        track: track,
                        size: hoverButtonSize,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Text(
            track.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            track.artist,
            style: TextStyle(
              color: theme.colorScheme.outline,
              fontSize: theme.textTheme.labelMedium?.fontSize,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          )
        ],
      ),
    );
  }

  Widget _buildAnimatedCover() {
    return ValueListenableBuilder(
      valueListenable: _playerState.playBackStateNotifier,
      builder: (_, PlayBackState stateValue, __) {
        bool isPlaying = stateValue == PlayBackState.playing;

        return ValueListenableBuilder(
          valueListenable: _playerState.trackNotifier,
          builder: (___, Track? currentTrack, Widget? ____) {
            bool isCurrent = currentTrack == track;

            if(!isCurrent || !isPlaying) {
              return SizedBox.shrink();
            }

            return TrackAnimationCover(
              bgColor: buttonColor,
              radius: hoverButtonSize,
              playAnimation: true,
            );
          },
        );
      },
    );
  }
}
