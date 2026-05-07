import 'package:flutter/material.dart';

import '/helpers/nav_keys.dart';
import '/l10n/app_localizations.dart';
import '/models/music_api_types.dart';
import '/services/app_state.dart';
import '/services/service_locator.dart';

class MainMenu extends StatefulWidget {
  const MainMenu({super.key});

  @override
  State<StatefulWidget> createState() => _MainMenu();
}

class _MainMenu extends State<MainMenu> {
  bool _collapsed = false;
  final _appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MainMenuItem(
          icon: const Icon(Icons.menu),
          text: '',
          collapsed: _collapsed,
          onTap: () {
            _collapsed = !_collapsed;
            setState(() {});
          },
        ),
        MainMenuItem(
          icon: const Icon(Icons.search),
          text: l10n.menu_search,
          collapsed: _collapsed,
          onTap: () => _goToRoute('/search'),
        ),
        MainMenuItem(
          icon: const Icon(Icons.radio_outlined),
          text: l10n.menu_stations,
          collapsed: _collapsed,
          onTap: () => _goToRoute('/stations'),
        ),
        MainMenuItem(
          icon: const Icon(Icons.music_note),
          text: l10n.menu_podcasts,
          collapsed: _collapsed,
          onTap: () => _goToRoute('/podcasts_books'),
        ),
        const SizedBox(height: 16),
        if (!_collapsed) Text(l10n.menu_myMusic),
        MainMenuItem(
          icon: const Icon(Icons.list),
          text: l10n.menu_tracks,
          collapsed: _collapsed,
          onTap: () => _goToRoute('/tracks'),
        ),
        MainMenuItem(
          icon: const Icon(Icons.album),
          text: l10n.menu_albums,
          collapsed: _collapsed,
          onTap: () => _goToRoute('/albums'),
        ),
        MainMenuItem(
          icon: const Icon(Icons.mic),
          text: l10n.menu_artists,
          collapsed: _collapsed,
          onTap: () => _goToRoute('/artists'),
        ),
        MainMenuItem(
          icon: const Icon(Icons.queue_music),
          text: l10n.menu_playlists,
          collapsed: _collapsed,
          onTap: () => _goToRoute('/playlists'),
        ),
        const Spacer(),
        MainMenuItem(
          icon: const Icon(Icons.settings),
          text: l10n.menu_settings,
          collapsed: _collapsed,
          onTap: () => _goToRoute('/settings'),
        ),
        ValueListenableBuilder(
            valueListenable: _appState.accountNotifier,
            builder: (_, Account? account, __) {
              return MainMenuItem(
                icon: const Icon(Icons.person),
                text: account == null ? 'User name' : account.displayName,
                collapsed: _collapsed,
                onTap: _appState.logout,
              );
            }),
        const SizedBox(height: 8),
      ],
    );
  }
}

void _goToRoute(String route) {
  // NavKeys.mainNav.currentState!.pushReplacementNamed(route);
  NavKeys.mainNav.currentState!.pushNamedAndRemoveUntil(route, (_) => false);
}

class MainMenuItem extends StatelessWidget {
  final Widget icon;
  final String text;
  final bool collapsed;
  final void Function()? onTap;
  final bool disabled;

  const MainMenuItem(
      {super.key,
      required this.icon,
      required this.text,
      required this.collapsed,
      this.onTap,
      this.disabled = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    TextStyle? textStyle;
    if (disabled) textStyle = TextStyle(color: theme.colorScheme.outline);

    return GestureDetector(
      onTap: onTap,
      child: MouseRegion(
        cursor: !disabled && onTap != null
            ? SystemMouseCursors.click
            : MouseCursor.defer,
        child: Row(
          children: [
            SizedBox(width: 42, height: 42, child: Center(child: icon)),
            if (!collapsed && text.isNotEmpty)
              SizedBox(width: 164, child: Text(text, style: textStyle))
          ],
        ),
      ),
    );
  }
}
