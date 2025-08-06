import 'package:flutter/material.dart';

import '/services/app_state.dart';
import '/services/music_api.dart';
import '/services/service_locator.dart';

class DeletePlaylistButton extends StatefulWidget {
  final int playlistKind;
  final void Function()? onDeleted;
  const DeletePlaylistButton({super.key, required this.playlistKind, this.onDeleted});

  @override
  State<DeletePlaylistButton> createState() => _DeletePlaylistButtonState();
}

class _DeletePlaylistButtonState extends State<DeletePlaylistButton> {
  final musicApi = getIt<MusicApi>();
  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    if(isDeleting) {
      return CircularProgressIndicator();
    }

    return TextButton(
      onPressed: () async {
        isDeleting = true;
        setState(() {});

        await musicApi.deletePlaylist(widget.playlistKind);
        getIt<AppState>().requestPlaylists();

        isDeleting = false;
        setState(() {});

        if(widget.onDeleted != null) widget.onDeleted!();
      },
      child: const Text('Delete'),
    );
  }
}
