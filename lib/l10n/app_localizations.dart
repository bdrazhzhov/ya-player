import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru')
  ];

  /// No description provided for @genre.
  ///
  /// In en, this message translates to:
  /// **'Genres'**
  String get genre;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @epoch.
  ///
  /// In en, this message translates to:
  /// **'Era'**
  String get epoch;

  /// No description provided for @personal.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get personal;

  /// No description provided for @editorial.
  ///
  /// In en, this message translates to:
  /// **'Editorial'**
  String get editorial;

  /// No description provided for @menu_main.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get menu_main;

  /// No description provided for @menu_stations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get menu_stations;

  /// No description provided for @menu_podcasts.
  ///
  /// In en, this message translates to:
  /// **'Podcasts and Books'**
  String get menu_podcasts;

  /// No description provided for @menu_myMusic.
  ///
  /// In en, this message translates to:
  /// **'My Music'**
  String get menu_myMusic;

  /// No description provided for @menu_tracks.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get menu_tracks;

  /// No description provided for @menu_albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get menu_albums;

  /// No description provided for @menu_artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get menu_artists;

  /// No description provided for @menu_playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get menu_playlists;

  /// No description provided for @menu_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menu_settings;

  /// No description provided for @page_main.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get page_main;

  /// No description provided for @page_stations.
  ///
  /// In en, this message translates to:
  /// **'Stations'**
  String get page_stations;

  /// No description provided for @page_podcasts.
  ///
  /// In en, this message translates to:
  /// **'Podcasts and Books'**
  String get page_podcasts;

  /// No description provided for @page_tracks.
  ///
  /// In en, this message translates to:
  /// **'Tracks'**
  String get page_tracks;

  /// No description provided for @page_albums.
  ///
  /// In en, this message translates to:
  /// **'Albums'**
  String get page_albums;

  /// No description provided for @page_artists.
  ///
  /// In en, this message translates to:
  /// **'Artists'**
  String get page_artists;

  /// No description provided for @page_playlists.
  ///
  /// In en, this message translates to:
  /// **'Playlists'**
  String get page_playlists;

  /// No description provided for @page_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get page_settings;

  /// No description provided for @settings_closeToTray.
  ///
  /// In en, this message translates to:
  /// **'Close to system tray'**
  String get settings_closeToTray;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @playlist.
  ///
  /// In en, this message translates to:
  /// **'PLAYLIST'**
  String get playlist;

  /// No description provided for @playlist_compiledBy.
  ///
  /// In en, this message translates to:
  /// **'Compiled by'**
  String get playlist_compiledBy;

  /// No description provided for @tracks_count.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0 {no tracks} =1 {track} other {tracks}}'**
  String tracks_count(int count);

  /// No description provided for @date_hoursShort.
  ///
  /// In en, this message translates to:
  /// **'hr'**
  String get date_hoursShort;

  /// No description provided for @date_minutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get date_minutesShort;

  /// No description provided for @tracks_headerTrack.
  ///
  /// In en, this message translates to:
  /// **'TRACK'**
  String get tracks_headerTrack;

  /// No description provided for @tracks_headerArtist.
  ///
  /// In en, this message translates to:
  /// **'ARTIST'**
  String get tracks_headerArtist;

  /// No description provided for @tracks_headerAlbum.
  ///
  /// In en, this message translates to:
  /// **'ALBUM'**
  String get tracks_headerAlbum;

  /// No description provided for @album_album.
  ///
  /// In en, this message translates to:
  /// **'ALBUM'**
  String get album_album;

  /// No description provided for @album_artist.
  ///
  /// In en, this message translates to:
  /// **'Artist'**
  String get album_artist;

  /// No description provided for @album_play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get album_play;

  /// No description provided for @album_like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get album_like;

  /// No description provided for @artist_artist.
  ///
  /// In en, this message translates to:
  /// **'ARTIST'**
  String get artist_artist;

  /// No description provided for @artist_play.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get artist_play;

  /// No description provided for @artist_like.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get artist_like;

  /// No description provided for @artist_station.
  ///
  /// In en, this message translates to:
  /// **'Station by artist'**
  String get artist_station;

  /// No description provided for @artist_popularTracks.
  ///
  /// In en, this message translates to:
  /// **'Popular Tracks'**
  String get artist_popularTracks;

  /// No description provided for @artist_popularAlbums.
  ///
  /// In en, this message translates to:
  /// **'Popular Albums'**
  String get artist_popularAlbums;

  /// No description provided for @artist_compilations.
  ///
  /// In en, this message translates to:
  /// **'Compilations'**
  String get artist_compilations;

  /// No description provided for @artist_similar.
  ///
  /// In en, this message translates to:
  /// **'Similar'**
  String get artist_similar;

  /// No description provided for @artist_official.
  ///
  /// In en, this message translates to:
  /// **'Official pages'**
  String get artist_official;

  /// No description provided for @artist_showAll.
  ///
  /// In en, this message translates to:
  /// **'Show all'**
  String get artist_showAll;

  /// No description provided for @artist_allAlbums.
  ///
  /// In en, this message translates to:
  /// **'All Albums'**
  String get artist_allAlbums;

  /// No description provided for @artist_albumsSortByRating.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get artist_albumsSortByRating;

  /// No description provided for @artist_albumsSortByYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get artist_albumsSortByYear;

  /// No description provided for @artist_albumsSortOrderAsc.
  ///
  /// In en, this message translates to:
  /// **'Ascending'**
  String get artist_albumsSortOrderAsc;

  /// No description provided for @artist_albumsSortOrderDesc.
  ///
  /// In en, this message translates to:
  /// **'Descending'**
  String get artist_albumsSortOrderDesc;

  /// No description provided for @artist_allCompilations.
  ///
  /// In en, this message translates to:
  /// **'All Albums'**
  String get artist_allCompilations;

  /// No description provided for @artist_allTracks.
  ///
  /// In en, this message translates to:
  /// **'All Tracks'**
  String get artist_allTracks;

  /// No description provided for @pageBlock_viewAll.
  ///
  /// In en, this message translates to:
  /// **'View all'**
  String get pageBlock_viewAll;

  /// No description provided for @chart_similarPlaylists.
  ///
  /// In en, this message translates to:
  /// **'Similar playlists'**
  String get chart_similarPlaylists;

  /// No description provided for @track_download.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get track_download;

  /// No description provided for @track_radio.
  ///
  /// In en, this message translates to:
  /// **'Station by track'**
  String get track_radio;

  /// No description provided for @track_addToPlaylist.
  ///
  /// In en, this message translates to:
  /// **'Add to playlist'**
  String get track_addToPlaylist;

  /// No description provided for @track_goToAlbum.
  ///
  /// In en, this message translates to:
  /// **'Go to album'**
  String get track_goToAlbum;

  /// No description provided for @track_goToArtists.
  ///
  /// In en, this message translates to:
  /// **'Go to artists'**
  String track_goToArtists(num count);

  /// No description provided for @track_share.
  ///
  /// In en, this message translates to:
  /// **'Copy link'**
  String get track_share;

  /// No description provided for @track_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get track_remove;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'ru': return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
