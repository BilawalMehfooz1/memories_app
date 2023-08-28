import 'package:flutter/material.dart';
import 'package:memories_app/widgets/auth_input_field.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  // var _enteredEmail = '';
  // var _enteredPassword = '';
  // var _enteredUsername = '';
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
                      child: Column(
                        children: [
                          Text(
                            'Memories',
                            style: style.textTheme.titleLarge,
                          ),
                          if (!_isLogin) const AuthInput(labelText: 'Username'),
                          const SizedBox(height: 12),
                          const AuthInput(labelText: 'Email Address'),
                          const SizedBox(height: 12),
                          const AuthInput(labelText: 'Password'),
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
                              padding: const EdgeInsets.symmetric(
                                vertical: 15,
                                horizontal: 130,
                              ),
                            ),
                            onPressed: () {},
                            child: const Text(
                              'Log in',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                          // const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'I already have an account',
                              style: TextStyle(
                                  color:
                                      style.colorScheme.onSecondaryContainer),
                            ),
                          ),
                        ],
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
