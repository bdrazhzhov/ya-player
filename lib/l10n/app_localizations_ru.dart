// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get genre => 'Стили';

  @override
  String get mood => 'Настроение';

  @override
  String get activity => 'Activity';

  @override
  String get epoch => 'Era';

  @override
  String get personal => 'Recommendations';

  @override
  String get editorial => 'Editorial';

  @override
  String get podcast_episodes => 'Выпуски подкастов';

  @override
  String get menu_main => 'Главное';

  @override
  String get menu_search => 'Поиск';

  @override
  String get menu_stations => 'Станции';

  @override
  String get menu_podcasts => 'Подкасты и книги';

  @override
  String get menu_myMusic => 'Моя музыка';

  @override
  String get menu_tracks => 'Треки';

  @override
  String get menu_albums => 'Альбомы';

  @override
  String get menu_artists => 'Исполнители';

  @override
  String get menu_playlists => 'Плейлисты';

  @override
  String get menu_settings => 'Настройки';

  @override
  String get page_main => 'Главная';

  @override
  String get page_stations => 'Станции';

  @override
  String get page_podcasts => 'Подкасты и книги';

  @override
  String get page_tracks => 'Треки';

  @override
  String get page_albums => 'Альбомы';

  @override
  String get page_artists => 'Исполнители';

  @override
  String get page_playlists => 'Плейлисты';

  @override
  String get page_settings => 'Настройки';

  @override
  String get settings_closeToTray => 'Сворачивать в трей, а не закрывать';

  @override
  String get settings_language => 'Язык';

  @override
  String get playlist => 'ПЛЕЙЛИСТ';

  @override
  String get playlist_compiledBy => 'Составитель';

  @override
  String tracks_count(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count треков',
      many: '$count треков',
      few: '$count трека',
      one: '1 трек',
      zero: 'нет треков',
    );
    return '$_temp0';
  }

  @override
  String get date_hoursShort => 'ч.';

  @override
  String get date_minutesShort => 'мин.';

  @override
  String get tracks_headerTrack => 'ТРЕК';

  @override
  String get tracks_headerArtist => 'ИСПОЛНИТЕЛЬ';

  @override
  String get tracks_headerAlbum => 'АЛЬБОМ';

  @override
  String get album_album => 'АЛЬБОМ';

  @override
  String get album_artist => 'Исполнитель';

  @override
  String get album_play => 'Воспроизвести';

  @override
  String get album_like => 'Нравится';

  @override
  String get artist_artist => 'ИСПОЛНИТЕЛЬ';

  @override
  String get artist_play => 'Воспроизвести';

  @override
  String get artist_like => 'Нравится';

  @override
  String get artist_station => 'Поток по исполнителю';

  @override
  String get artist_popularTracks => 'Популярные треки';

  @override
  String get artist_popularAlbums => 'Популярные альбомы';

  @override
  String get artist_compilations => 'Сборники';

  @override
  String get artist_similar => 'Похожие';

  @override
  String get artist_official => 'Официальные страницы';

  @override
  String get artist_showAll => 'Показать все';

  @override
  String get artist_allAlbums => 'Все альбомы';

  @override
  String get artist_albumsSortByRating => 'Рейтинг';

  @override
  String get artist_albumsSortByYear => 'Год';

  @override
  String get artist_albumsSortOrderAsc => 'По возрастанию';

  @override
  String get artist_albumsSortOrderDesc => 'По убыванию';

  @override
  String get artist_allCompilations => 'Все сборники';

  @override
  String get artist_allTracks => 'Все треки';

  @override
  String get pageBlock_viewAll => 'Смотреть всё';

  @override
  String get chart_similarPlaylists => 'Плейлисты с другими чартами';

  @override
  String get track_download => 'Скачать';

  @override
  String get track_radio => 'Поток по треку';

  @override
  String get track_addToPlaylist => 'Добавить в плейлист';

  @override
  String get track_goToAlbum => 'Перейти к альбому';

  @override
  String track_goToArtists(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'исполнителям',
      one: 'исполнителю',
    );
    return 'Перейти к $_temp0';
  }

  @override
  String get track_share => 'Поделиться';

  @override
  String get track_remove => 'Удалить из фонотеки';

  @override
  String get search_filters_top => 'Топ';

  @override
  String get search_filters_track => 'Треки';

  @override
  String get search_filters_artist => 'Исполнители';

  @override
  String get search_filters_album => 'Альбомы';

  @override
  String get search_filters_playlist => 'Плейлисты';

  @override
  String get search_filters_podcast => 'Подкасты';

  @override
  String get search_filters_book => 'Аудиокниги';

  @override
  String get searchbar_hint => 'Трек, альбом, исполнитель';
}
