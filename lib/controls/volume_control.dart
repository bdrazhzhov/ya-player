import 'dart:async';

import 'package:flutter/material.dart';

import '/audio_player.dart';
import '/services/service_locator.dart';

class VolumeControl extends StatefulWidget {
  const VolumeControl({
    super.key,
  });

  @override
  State<VolumeControl> createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  final audioPlayer = getIt<AudioPlayer>();
  bool isVolumeChangedInternally = false;
  late StreamSubscription<PlaybackEventMessage> playbackEventsSubscription;

  @override
  void initState() {
    super.initState();

    playbackEventsSubscription = audioPlayer.playbackEventMessageStream.listen((PlaybackEventMessage msg){
      if(isVolumeChangedInternally) return;

      isVolumeChangedInternally = false;
      setState(() {});
    });
  }


  @override
  void dispose() {
    playbackEventsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Slider(
      value: audioPlayer.volume,
      onChanged: (double value) async {
        isVolumeChangedInternally = true;
        await audioPlayer.setVolume(value);
        setState((){});
      },
    );
  }
}
