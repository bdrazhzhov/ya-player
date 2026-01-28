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

  // @override
  // void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
  //   // print('Route: $route');
  //   // print('Previous route: $previousRoute');
  //   super.didRemove(route, previousRoute);
  //   final name = route.settings.name;
  //   print('Удалён маршрут: $name');
  //   if (route is PageRoute) {
  //     print('PageRoute удалён: ${route.runtimeType}, settings=${route.settings}');
  //   } else {
  //     print('Другой тип маршрута удалён: ${route.runtimeType}');
  //   }
  // }
}
