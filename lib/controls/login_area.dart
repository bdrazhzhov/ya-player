import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginArea extends StatelessWidget {
  final List<Widget> children;

  const LoginArea({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 32.0),
      decoration: BoxDecoration(color: theme.colorScheme.surface),
      child: Center(
        child: Container(
          width: 360,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.onSurface, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Container(
                  width: 106,
                  height: 44,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.onSurface, width: 2),
                      borderRadius: const BorderRadius.all(Radius.circular(22))
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/ya_logo.svg',
                        // colorFilter: ColorFilter.mode(theme.colorScheme.onBackground, BlendMode.srcIn),
                        width: 26,
                        height: 26,
                      ),
                      SvgPicture.asset(
                        'assets/svg/id_logo.svg',
                        colorFilter: ColorFilter.mode(theme.colorScheme.onSurface, BlendMode.srcIn),
                        width: 26,
                        height: 26,
                      ),
                      SvgPicture.asset(
                        'assets/svg/id_logo_name.svg',
                        colorFilter: ColorFilter.mode(theme.colorScheme.onSurface, BlendMode.srcIn),
                        width: 26,
                        height: 26,
                      ),
                    ],
                  ),
                ),
              ),
              ...children
            ],
          ),
        ),
      ),
    );
  }
}
