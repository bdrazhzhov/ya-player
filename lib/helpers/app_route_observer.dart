import 'package:flutter/material.dart';

class AppRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final popNotifier = ValueNotifier<bool>(false);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);

    if (route.navigator == null) return;

    popNotifier.value = route.navigator!.canPop();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);

    popNotifier.value = route.navigator!.canPop();
    // debugPrint('Can pop: ${popNotifier.value}');
  }
}
