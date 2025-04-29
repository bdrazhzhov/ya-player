import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/controls/station/stations_grid.dart';
import '/pages/page_base.dart';
import '/controls/dashboard_stations.dart';
import '/models/music_api_types.dart';
import '/services/app_state.dart';
import '/services/music_api.dart';
import '/services/service_locator.dart';

class StationsPage extends StatelessWidget {
  final GlobalKey<NavigatorState> _navKey = GlobalKey();

  StationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: _navKey,
      initialRoute: '/',
      onGenerateRoute: (RouteSettings settings){
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) => _StationsWidget()
        );
      },
    );
  }
}

class _StationsWidget extends StatelessWidget {
  final musicApi = getIt<MusicApi>();

  _StationsWidget();

  late final Future<StationsDashboard> dashboard;

  final appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final i10n = AppLocalizations.of(context);
    final genreNames = {
      'genre': i10n?.genre,
      'mood': i10n?.mood,
      'activity': i10n?.activity,
      'epoch': i10n?.epoch,
      'personal': i10n?.personal,
      'editorial': i10n?.editorial
    };

    return ValueListenableBuilder(
      valueListenable: appState.stationsNotifier,
      builder: (_, groups, __) {
        List<Widget> widgets = [];

        groups.forEach((String groupName, List<Station> stations) {
          widgets.addAll(
            [
              SliverText(
                text: genreNames[groupName] ?? 'No translation',
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                style: theme.textTheme.headlineSmall,
              ),
              StationsGrid(stations: stations)
            ],
          );
        });

        return PageBase(slivers: [
          SliverText(
            text: AppLocalizations.of(context)!.page_stations,
            padding: const EdgeInsets.only(top: 12, bottom: 38),
            style: theme.textTheme.headlineLarge,
          ),
          DashboardStations(),
          ...widgets,
        ]);
      },
    );
  }
}

class SliverText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final EdgeInsetsGeometry? padding;

  const SliverText({super.key, required this.text, this.style, this.padding});

  @override
  Widget build(BuildContext context) {
    final widget = SliverToBoxAdapter(
      child: Text(
        text,
        style: style,
      ),
    );

    if(padding == null) return widget;

    return SliverPadding(
      padding: padding!,
      sliver: widget,
    );
  }
}
