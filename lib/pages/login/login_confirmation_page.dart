import 'package:flutter/material.dart';

import '../../controls/login_area.dart';
import '../../helpers/ym_login.dart';
import 'confirmation_code_page.dart';

class LoginConfirmationPage extends StatefulWidget {
  final String hint;
  final String phoneId;

  const LoginConfirmationPage({super.key, required this.hint, required this.phoneId});

  @override
  State<LoginConfirmationPage> createState() => _LoginConfirmationPageState();
}

class _LoginConfirmationPageState extends State<LoginConfirmationPage> {
  bool _isLoading = false;
  final bool _isError = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LoginArea(
      children: [
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
                  child: Text(widget.hint, style: theme.textTheme.titleLarge),
                ),
              ],
            )
        ),

        SizedBox(
          height: 56,
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _isLoading || _isError ? null : () async {
              _isLoading = true;
              setState(() {});
              final Map<String, dynamic> data = await requestConfirmationSms(widget.phoneId);
              if(data['status'] != 'ok') {
                throw 'Error during phone confirmation code submitting: $data';
              }
              _isLoading = false;
              setState(() {});

              final remainingTime = Duration(milliseconds: data['deny_resend_until'] * 1000 - DateTime.now().millisecondsSinceEpoch);

              Navigator.push(context, PageRouteBuilder(
                pageBuilder: (_, __, ___) => ConfirmationCodePage(
                  hint: widget.hint,
                  phoneId: widget.phoneId,
                  remainingTime: remainingTime
                ),
                reverseTransitionDuration: Duration.zero,
              ));
            },
            child: _isLoading ? const CircularProgressIndicator() : const Text('Confirm'),
          ),
        )
      ],
    );
  }
}
