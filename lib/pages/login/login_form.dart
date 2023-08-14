import 'package:flutter/material.dart';

import '../../app_state.dart';
import '../../controls/login_area.dart';
import '../../helpers/ym_login.dart';
import '../../services/service_locator.dart';
import 'login_confirmation_page.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final appState = getIt<AppState>();
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isValid = false;
  bool _isDirty = false;
  bool _isLoading = false;

  void _onSubmit() async {
    setState(() {
      _isDirty = true;
      _isValid = _formKey.currentState!.validate();
    });
    if(!_isValid) return;

    _isLoading = true;
    setState(() {});

    final LoginResult result = await ymLogin(_loginController.text, _passwordController.text);
    if(result.state == LoginState.finished) {
      await appState.login(YmToken.fromJson(result.data));
    }
    else if(result.state == LoginState.needSms) {
      Navigator.push(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => LoginConfirmationPage(
          hint: result.data['hint'],
          phoneId: result.data['phoneId'].toString()
        ),
        reverseTransitionDuration: Duration.zero,
      ));
    }

    _isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      onChanged: (){
        setState(() {
          if(_isDirty) {
            _isValid = _formKey.currentState!.validate();
          }
        });
      },
      child: LoginArea(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Login'),
            controller: _loginController,
            validator: (value) {
              if(value == null || value.isEmpty) {
                return 'is required';
              }
              return null;
            },
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
            controller: _passwordController,
            validator: (value) {
              if(value == null || value.isEmpty) {
                return 'is required';
              }
              return null;
            },
          ),
          const SizedBox(height: 102,),
          SizedBox(
            height: 56,
            width: double.infinity,
            child: OutlinedButton(
              onPressed: !_isLoading && (!_isDirty || _isValid) ? _onSubmit : null,
              child: _isLoading ? const CircularProgressIndicator() : const Text('Submit')
            ),
          )
        ],
      ),
    );
  }
}
