import 'package:flutter/material.dart';

import '/app_state.dart';
import '/services/service_locator.dart';
import 'page_base.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _appState = getIt<AppState>();
  
  @override
  Widget build(BuildContext context) {
    return PageBase(
      title: 'Settings',
      slivers: [
        SliverList.list(
          children: [
            ListTile(
              title: const Text('Close to system tray'),
              trailing: ValueListenableBuilder(
                valueListenable: _appState.closeToTrayEnabledNotifier,
                builder: (_, bool isEnabled, __) {
                  return Switch(
                    value: isEnabled,
                    onChanged: (bool value) {
                      _appState.closeToTrayEnabledNotifier.value = value;
                    },
                  );
                },
              ),
              onTap: () {
                _appState.closeToTrayEnabledNotifier.value = !_appState.closeToTrayEnabledNotifier.value;
              },
            ),
            ListTile(
              title: const Text('Language'),
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
