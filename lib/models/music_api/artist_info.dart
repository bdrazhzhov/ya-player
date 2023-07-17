import 'package:ya_player/models/music_api/track.dart';

import 'album.dart';
import 'artist.dart';

class ArtistInfo {
  final LikedArtist artist;
  final List<Album> albums;
  final List<Album> alsoAlbums;
  final List<Track> popularTracks;
  final List<LikedArtist> similarArtists;

  ArtistInfo(this.artist, this.albums, this.alsoAlbums,
      this.popularTracks, this.similarArtists);

  factory ArtistInfo.fromJson(Map<String, dynamic> json) {
    final data = json['result'];

    List<Album> albums = [];
    data['albums'].forEach((album) => albums.add(Album.fromJson(album)));

    List<Album> alsoAlbums = [];
    data['alsoAlbums'].forEach((album) => alsoAlbums.add(Album.fromJson(album)));

    List<Track> popularTracks = [];
    data['popularTracks'].forEach((track) => popularTracks.add(Track.fromJson(track, '')));

    List<LikedArtist> similarArtists = [];
    data['similarArtists'].forEach((artist) => similarArtists.add(LikedArtist.fromJson(artist)));

    return ArtistInfo(LikedArtist.fromJson(data['artist']), albums,
        alsoAlbums, popularTracks, similarArtists);
  }
}
