import 'package:flutter/material.dart';

import '/l10n/app_localizations.dart';
import '/app_state.dart';
import '/services/service_locator.dart';

class LanguageSelector extends StatelessWidget {
  final _appState = getIt<AppState>();

  LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _appState.localeNotifier,
      builder: (_, Locale lang, __) {
        return SegmentedButton<Locale>(
          selected: {lang},
          showSelectedIcon: false,
          segments: AppLocalizations.supportedLocales.map((locale) => ButtonSegment(
            value: locale,
            label: Text(locale.languageCode),
          )).toList(),
          onSelectionChanged: (Set<Locale> value) {
            _appState.localeNotifier.value = value.first;
          },
        );
      },
    );
  }
}
