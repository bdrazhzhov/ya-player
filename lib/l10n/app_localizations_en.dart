// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get genre => 'Genres';

  @override
  String get mood => 'Mood';

  @override
  String get activity => 'Activity';

  @override
  String get epoch => 'Era';

  @override
  String get personal => 'Recommendations';

  @override
  String get editorial => 'Editorial';

  @override
  String get podcast_episodes => 'Podcast episodes';

  @override
  String get menu_main => 'Main';

  @override
  String get menu_search => 'Search';

  @override
  String get menu_stations => 'Stations';

  @override
  String get menu_podcasts => 'Podcasts and Books';

  @override
  String get menu_myMusic => 'My Music';

  @override
  String get menu_tracks => 'Tracks';

  @override
  String get menu_albums => 'Albums';

  @override
  String get menu_artists => 'Artists';

  @override
  String get menu_playlists => 'Playlists';

  @override
  String get menu_settings => 'Settings';

  @override
  String get page_main => 'Home';

  @override
  String get page_stations => 'Stations';

  @override
  String get page_podcasts => 'Podcasts and Books';

  @override
  String get page_tracks => 'Tracks';

  @override
  String get page_albums => 'Albums';

  @override
  String get page_artists => 'Artists';

  @override
  String get page_playlists => 'Playlists';

  @override
  String get page_settings => 'Settings';

  @override
  String get settings_closeToTray => 'Close to system tray';

  @override
  String get settings_language => 'Language';

  @override
  String get playlist => 'PLAYLIST';

  @override
  String get playlist_compiledBy => 'Compiled by';

  @override
  String tracks_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'tracks',
      one: 'track',
      zero: 'no tracks',
    );
    return '$_temp0';
  }

  @override
  String get date_hoursShort => 'hr';

  @override
  String get date_minutesShort => 'min';

  @override
  String get tracks_headerTrack => 'TRACK';

  @override
  String get tracks_headerArtist => 'ARTIST';

  @override
  String get tracks_headerAlbum => 'ALBUM';

  @override
  String get album_album => 'ALBUM';

  @override
  String get album_artist => 'Artist';

  @override
  String get album_play => 'Play';

  @override
  String get album_like => 'Like';

  @override
  String get artist_artist => 'ARTIST';

  @override
  String get artist_play => 'Play';

  @override
  String get artist_like => 'Like';

  @override
  String get artist_station => 'Station by artist';

  @override
  String get artist_popularTracks => 'Popular Tracks';

  @override
  String get artist_popularAlbums => 'Popular Albums';

  @override
  String get artist_compilations => 'Compilations';

  @override
  String get artist_similar => 'Similar';

  @override
  String get artist_official => 'Official pages';

  @override
  String get artist_showAll => 'Show all';

  @override
  String get artist_allAlbums => 'All Albums';

  @override
  String get artist_albumsSortByRating => 'Rating';

  @override
  String get artist_albumsSortByYear => 'Year';

  @override
  String get artist_albumsSortOrderAsc => 'Ascending';

  @override
  String get artist_albumsSortOrderDesc => 'Descending';

  @override
  String get artist_allCompilations => 'All Albums';

  @override
  String get artist_allTracks => 'All Tracks';

  @override
  String get pageBlock_viewAll => 'View all';

  @override
  String get chart_similarPlaylists => 'Similar playlists';

  @override
  String get track_download => 'Download';

  @override
  String get track_radio => 'Station by track';

  @override
  String get track_addToPlaylist => 'Add to playlist';

  @override
  String get track_goToAlbum => 'Go to album';

  @override
  String track_goToArtists(num count) {
    return 'Go to artists';
  }

  @override
  String get track_share => 'Copy link';

  @override
  String get track_remove => 'Remove';

  @override
  String get search_filters_top => 'Top';

  @override
  String get search_filters_track => 'Tracks';

  @override
  String get search_filters_artist => 'Artists';

  @override
  String get search_filters_album => 'Albums';

  @override
  String get search_filters_playlist => 'Playlists';

  @override
  String get search_filters_podcast => 'Podcasts';

  @override
  String get search_filters_book => 'Books';

  @override
  String get searchbar_hint => 'Track, album, artist';

  @override
  String get track_card_track => 'Track';

  @override
  String get new_releases_title => 'New releases';

  @override
  String get new_releases_subtitle => 'New tracks, albums and mixes';

  @override
  String get popular_playlists_title => 'Popular playlists';

  @override
  String get popular_playlists_subtitle => 'Collected for you';
}
