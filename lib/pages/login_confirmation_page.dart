import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoginConfirmationPage extends StatelessWidget {
  final String hint;

  const LoginConfirmationPage({super.key, required this.hint});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.only(top: 32.0),
      decoration: BoxDecoration(color: theme.colorScheme.background),
      child: Center(
        child: Container(
          width: 360,
          height: 476,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.onBackground, width: 2),
            borderRadius: const BorderRadius.all(Radius.circular(32)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 32),
                child: Container(
                  width: 110,
                  height: 44,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    border: Border.all(color: theme.colorScheme.onBackground, width: 2),
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
                        colorFilter: ColorFilter.mode(theme.colorScheme.onBackground, BlendMode.srcIn),
                        width: 26,
                        height: 26,
                      ),
                      SvgPicture.asset(
                        'assets/svg/id_logo_name.svg',
                        colorFilter: ColorFilter.mode(theme.colorScheme.onBackground, BlendMode.srcIn),
                        width: 26,
                        height: 26,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text('Безопасный вход', style: theme.textTheme.titleLarge),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 36),
                child: SizedBox(
                  width: 300,
                  child: Text('Нажмите кнопку «Подтвердить», если вы можете принять звонок'
                      ' или сообщение на указанный номер. Это нужно для завершения входа.'),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your phone number:'),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 30, top: 10),
                      child: Text(hint, style: theme.textTheme.titleLarge,),
                    ),
                  ],
                )
              ),

              SizedBox(
                height: 56,
                width: double.infinity,
                child: OutlinedButton(
                  child: const Text('Confirm'),
                  onPressed: (){},
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
