import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/app_state.dart';
import '/services/service_locator.dart';
import 'page_base.dart';
import '/controls/settings/language_selector.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PageBase(
      title: l10n.page_settings,
      slivers: [
        SliverList.list(
          children: [
            ListTile(
              title: Text(l10n.settings_closeToTray),
              trailing: ValueListenableBuilder(
                valueListenable: appState.closeToTrayEnabledNotifier,
                builder: (_, bool isEnabled, __) {
                  return Switch(
                    value: isEnabled,
                    onChanged: (bool value) {
                      appState.closeToTrayEnabledNotifier.value = value;
                    },
                  );
                },
              ),
              onTap: () {
                appState.closeToTrayEnabledNotifier.value = !appState.closeToTrayEnabledNotifier.value;
              },
            ),
            ListTile(
              title: Text(l10n.settings_language),
              trailing: LanguageSelector(),
              // onTap: () {
              //
              // },
            ),
            ListTile(
              title: const Text('About'),
              // onTap: () {
              //
              // },
            ),
          ]
        )
      ],
    );
  }
}
