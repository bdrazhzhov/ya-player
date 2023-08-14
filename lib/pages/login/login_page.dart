import 'package:flutter/material.dart';

import '../../helpers/nav_keys.dart';
import 'login_form.dart';
import '../../helpers/app_route_observer.dart';
import '../../services/service_locator.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: NavKeys.loginNav,
      observers: [getIt<AppRouteObserver>()],
      onGenerateRoute: (RouteSettings settings){
        return PageRouteBuilder(
          pageBuilder: (_, __, ___) {
            return const LoginForm();
          }
        );
      },
    );
  }
}
