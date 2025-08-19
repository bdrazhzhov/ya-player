import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/services/app_state.dart';
import '/services/music_api.dart';
import '/services/service_locator.dart';
import '/models/music_api/playlist.dart';

class CreatePlaylistButton extends StatefulWidget {
  final void Function(Playlist)? onCreated;

  const CreatePlaylistButton({super.key, this.onCreated});

  @override
  State<CreatePlaylistButton> createState() => _CreatePlaylistButtonState();
}

class _CreatePlaylistButtonState extends State<CreatePlaylistButton> {
  bool isCreating = false;

  @override
  Widget build(BuildContext context) {
    if(isCreating) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: CircularProgressIndicator(),
      );
    }

    return IconButton(
      onPressed: createPlaylist,
      icon: const Icon(Icons.add),
      tooltip: AppLocalizations.of(context)!.playlist_create,
    );
  }
  
  void createPlaylist() async {
    isCreating = true;
    setState(() {});

    final Playlist playlist = await getIt<MusicApi>().createPlaylist('Новый плейлист');
    getIt<AppState>().requestPlaylists();

    isCreating = false;
    setState(() {});

    if(widget.onCreated != null) widget.onCreated!(playlist);
  }
}
