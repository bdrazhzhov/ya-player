import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:ya_player/controls/error_dialog.dart';
import 'package:ya_player/controls/login_area.dart';

import '../../app_state.dart';
import '../../helpers/ym_login.dart';
import '../../services/service_locator.dart';

class ConfirmationCodePage extends StatefulWidget {
  final String hint;
  final String phoneId;
  final Duration remainingTime;

  const ConfirmationCodePage({
    super.key,
    required this.hint,
    required this.phoneId,
    required this.remainingTime
  });

  @override
  State<ConfirmationCodePage> createState() => _ConfirmationCodePageState();
}

class _ConfirmationCodePageState extends State<ConfirmationCodePage> {
  static const countDownInterval = Duration(seconds: 1);
  late Duration remainingTime;
  late Timer countDownTimer;
  final formKey = GlobalKey<FormState>();
  bool isValid = false;
  bool isDirty = false;
  bool isLoading = false;
  var maskFormatter = MaskTextInputFormatter(
    mask: '### ###',
    filter: { "#": RegExp(r'[0-9]') },
    type: MaskAutoCompletionType.lazy
  );
  final codeController = TextEditingController();
  final appState = getIt<AppState>();

  @override
  void initState() {
    super.initState();
    remainingTime = widget.remainingTime;
    countDownTimer = Timer.periodic(countDownInterval, onTimerTick);
  }

  void onTimerTick(Timer timer) {
    if(remainingTime <= Duration.zero) {
      timer.cancel();
      remainingTime = Duration.zero;
    }
    else {
      remainingTime -= countDownInterval;
    }

    if(timer.isActive) setState(() {});
  }

  void resendCode() async {
    final Map<String, dynamic> data = await requestConfirmationSms(widget.phoneId);
    if(data['status'] != 'ok') {
      throw 'Error during phone confirmation code submitting: $data';
    }

    remainingTime = Duration(milliseconds: data['deny_resend_until'] * 1000 - DateTime.now().millisecondsSinceEpoch);
    countDownTimer = Timer.periodic(countDownInterval, onTimerTick);
    setState(() {});
  }

  void onSubmit() async {
    isDirty = true;
    isValid = formKey.currentState!.validate();

    setState(() {});

    if(!isValid) return;

    isLoading = true;
    setState(() {});

    try {
      final Map<String, dynamic> result = await checkConfirmationCode(codeController.text);
      if(result['status'] == 'ok') {
        final LoginResult result = await finishAuth();
        await appState.login(YmToken.fromJson(result.data));
      }
      else if(result['status'] == 'error') {
        final List<String> errors = (result['errors'] as List).map((i) => i.toString()).toList();
        String errorMessage = 'Unknown error';
        if(errors.contains('code.invalid') || errors.contains('code.empty')){
          errorMessage = 'Invalid confirmation code';
        }
        else if(errors.contains('track.not_found')) {
          errorMessage = 'Try login again';
        }

        showErrorDialog(context, errorMessage);
      }
    }
    catch (e) {
      showErrorDialog(context, e.toString());
    }

    isLoading = false;
    setState(() {});
  }

  @override
  void dispose() {
    super.dispose();
    countDownTimer.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String remainingString = '';
    if(remainingTime > Duration.zero) {
      remainingString = ' ${remainingTime.inMinutes.toString().padLeft(2, '0')}:'
          '${(remainingTime.inSeconds - remainingTime.inMinutes * 60).toString().padLeft(2, '0')}';
    }

    return Form(
      key: formKey,
      onChanged: (){
        setState(() {
          if(isDirty) {
            isValid = formKey.currentState!.validate();
          }
        });
      },
      child: LoginArea(children: [
        Text(
          'Введите код из СМС, отправленный на номер \n${widget.hint}',
          style: theme.textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 36, top: 32),
          child: TextFormField(
            controller: codeController,
            inputFormatters: [maskFormatter],
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
            validator: (value) {
              if(value == null || value.isEmpty) {
                return 'is required';
              }
              return null;
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton(
              onPressed: isLoading ? null : onSubmit,
              child: const Text('Next')
            )
          ),
        ),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: remainingTime <= Duration.zero && !isLoading ? resendCode : null,
            child: Text('Отправить еще код$remainingString'),
          ),
        )
      ]),
    );
  }
}
