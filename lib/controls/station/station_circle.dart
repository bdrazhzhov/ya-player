import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:ya_player/helpers/color_extension.dart';

import '/app_state.dart';
import '/models/music_api/station.dart';
import '/music_api.dart';
import '/notifiers/play_button_notifier.dart';
import '/services/service_locator.dart';
import 'animated_station_circle.dart';

class StationCircle extends StatelessWidget {
  final double dimension;
  final double imageDimension;
  final int imageSourceDimension;
  final Station station;

  late final _image = Center(
    child: CachedNetworkImage(
      width: imageDimension.toDouble(),
      height: imageDimension.toDouble(),
      fit: BoxFit.fitWidth,
      imageUrl: MusicApi.imageUrl(station.icon.imageUrl, '${imageSourceDimension}x$imageSourceDimension').toString(),
      placeholder: (context, url) => const CircularProgressIndicator(),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    )
  );

  final _appState = getIt<AppState>();

  StationCircle({
    super.key,
    required this.dimension,
    required this.imageDimension,
    required this.imageSourceDimension,
    required this.station
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _appState.playButtonNotifier,
      builder: (BuildContext context, buttonState, Widget? child) {
        return ValueListenableBuilder(
          valueListenable: _appState.currentStationNotifier,
          builder: (_, currentStation, Widget? child) {
            if(buttonState == ButtonState.playing && currentStation == station) {
              return AnimatedStationCircle(
                color: station.icon.backgroundColor.toColor(),
                maxWidth: dimension,
                child: child!,
              );
            }

            return SizedBox.square(
              dimension: dimension,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: station.icon.backgroundColor.toColor(),
                  shape: BoxShape.circle
                ),
                child: child,
              ),
            );
          },
          child: _image,
        );
      },
    );
  }
}
