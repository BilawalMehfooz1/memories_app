import 'package:flutter/material.dart';
import 'package:memories_app/widgets/auth_input_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = false;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                margin: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _form,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return Column(
                            children: [
                              Text(
                                'Memories',
                                style: style.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 30),
                              if (!_isLogin)
                                AuthInput(
                                  obsecureText: false,
                                  labelText: 'Username',
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value == null ||
                                        !value.contains('@') ||
                                        value.trim().isEmpty) {
                                      return 'Please enter atleast 4 characters.';
                                    }
                                    return null;
                                  },
                                ),
                              const SizedBox(height: 15),
                              AuthInput(
                                obsecureText: false,
                                labelText: 'Email Address',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 4 ||
                                      value.trim().isEmpty) {
                                    return 'Please enter a valid email address.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              AuthInput(
                                labelText: 'Password',
                                obsecureText: true,
                                keyboardType: TextInputType.text,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().length < 6) {
                                    return 'Password must be at least 6 characters long.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      style.colorScheme.primaryContainer,
                                  foregroundColor:
                                      style.colorScheme.onPrimaryContainer,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(15),
                                    ),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 15,
                                    horizontal: (constraints.maxWidth - 70) / 2,
                                  ),
                                ),
                                onPressed: () {},
                                child: Text(
                                  _isLogin ? 'Log in' : 'Sign up',
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                  });
                                },
                                child: Text(
                                  _isLogin
                                      ? 'Create an account'
                                      : 'I already have an account',
                                  style: TextStyle(
                                    color: Colors.grey[800],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
