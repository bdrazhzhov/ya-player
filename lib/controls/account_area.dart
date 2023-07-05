import 'package:flutter/material.dart';
import 'package:ya_player/app_state.dart';
import 'package:ya_player/services/service_locator.dart';

import '../models/music_api/account.dart';
import 'login_dialog.dart';

class AccountArea extends StatelessWidget {
  final appState = getIt<AppState>();

  AccountArea({super.key,});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Account?>(
      valueListenable: appState.accountNotifier,
      builder: (_, account, __) {
        if(account == null) {
          return TextButton(
            child: const Text('Login'),
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const LoginDialog();
                  }
              );
            },
          );
        }
        else {
          return Row(
            children: [
              Text(account.fullName),
              TextButton(
                onPressed: appState.logout,
                child: const Text('logout')
              )
            ],
          );
        }
      },
    );
  }
}
