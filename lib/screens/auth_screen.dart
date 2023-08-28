import 'package:flutter/material.dart';
import 'package:memories_app/widgets/auth_input_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _isLogin = false;

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
                                const AuthInput(
                                  obsecureText: false,
                                  labelText: 'Username',
                                  keyboardType: TextInputType.name,
                                ),
                              const SizedBox(height: 15),
                              const AuthInput(
                                obsecureText: false,
                                labelText: 'Email Address',
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 15),
                              const AuthInput(
                                labelText: 'Password',
                                obsecureText: true,
                                keyboardType: TextInputType.text,
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
                                    horizontal: (constraints.maxWidth - 60) / 2,
                                  ),
                                ),
                                onPressed: () {},
                                child: const Text(
                                  'Log in',
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  'I already have an account',
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
