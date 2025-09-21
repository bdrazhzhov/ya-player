import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/models/music_api/playlist.dart';
import '/services/app_state.dart';
import '/services/music_api.dart';
import '/services/service_locator.dart';

class DeletePlaylistButton extends StatefulWidget {
  final Playlist playlist;
  final void Function()? onDeleted;
  const DeletePlaylistButton({super.key, required this.playlist, this.onDeleted});

  @override
  State<DeletePlaylistButton> createState() => _DeletePlaylistButtonState();
}

class _DeletePlaylistButtonState extends State<DeletePlaylistButton> {
  final musicApi = getIt<MusicApi>();
  final appState = getIt<AppState>();
  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    if (isDeleting) {
      return CircularProgressIndicator();
    }

    final l10n = AppLocalizations.of(context)!;
    final bool isEditable = appState.isPlaylistEditable(widget.playlist);

    return IconButton(
      onPressed: isEditable ? onPressed : null,
      icon: const Icon(Icons.delete),
      tooltip: isEditable ? l10n.playlist_delete : null,
    );
  }

  void onPressed() async {
    isDeleting = true;
    setState(() {});

    await musicApi.deletePlaylist(widget.playlist);
    appState.requestPlaylists();

    isDeleting = false;
    setState(() {});

    if (widget.onDeleted != null) widget.onDeleted!();
  }
}
