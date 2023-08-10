import 'package:flutter/material.dart';

import 'login_confirmation_page.dart';
import '../app_state.dart';
import '../services/service_locator.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _appState = getIt<AppState>();
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isValid = false;
  bool _isDirty = false;
  bool _showRetry = false;

  void _onSubmit() async {
    setState(() {
      _isDirty = true;
      _isValid = _formKey.currentState!.validate();
    });
    if(!_isValid) return;

    // LoginState loginState = await _appState.login(_loginController.text, _passwordController.text);
    // if(loginState == LoginState.success) {
    //   Navigator.pop(context);
    // }
    // else if(loginState == LoginState.browserAction) {
    //   _showRetry = true;
    //   _isDirty = false;
    //   setState(() {});
    // }
    // else if(loginState == LoginState.failure) {
    //   // Failure
    // }

    Navigator.push(context, PageRouteBuilder(
      pageBuilder: (_, __, ___) => const LoginConfirmationPage(hint: '123',),
      reverseTransitionDuration: Duration.zero,
    ));
  }

  void _onRetry() async {
    setState(() {
      _isDirty = true;
      _isValid = _formKey.currentState!.validate();
    });
    if(!_isValid) return;

    LoginState loginState = await _appState.login(_loginController.text, _passwordController.text);
    if(loginState == LoginState.success) {
      Navigator.pop(context);
    }
    else if(loginState == LoginState.failure) {
      // Failure
    }
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
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
          const SizedBox(height: 50,),
          if(_showRetry)
            ElevatedButton(
                onPressed: !_isDirty || _isValid ? _onRetry : null,
                child: const Text('Retry')
            )
          else
            ElevatedButton(
                onPressed: !_isDirty || _isValid ? _onSubmit : null,
                child: const Text('Submit')
            )
        ],
      ),
    );
  }
}
