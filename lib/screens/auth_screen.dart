import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter/material.dart';
import 'package:memories_app/widgets/auth_data/auth_input_field.dart';
import 'package:memories_app/widgets/auth_data/user_image_picker.dart';

final _firebase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredUserName = '';
  var _confirmPassword = '';
  File? _selectedImage;
  var _isLogin = true;
  var _isAuthenticating = false;

  void _submit() async {
    UserCredential userCredentials;

    if (!_isLogin && _selectedImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a profile image.'),
        ),
      );
      return;
    }

    _form.currentState!.save();

    if (!_isLogin && _enteredPassword != _confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match!'),
        ),
      );
      return;
    }

    setState(() {
      _isAuthenticating = true;
    });

    try {
      if (_isLogin) {
        userCredentials = await _firebase.signInWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );
      } else {
        userCredentials = await _firebase.createUserWithEmailAndPassword(
          email: _enteredEmail,
          password: _enteredPassword,
        );

        final storageRef = FirebaseStorage.instance
            .ref()
            .child('user_images')
            .child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrl = await storageRef.getDownloadURL();

        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredentials.user!.uid)
            .set({
          'username': _enteredUserName,
          'email': _enteredEmail,
          'image_url': imageUrl,
        });
      }
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              error.message ?? 'Authentication failed.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAuthenticating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context);

    return Scaffold(
      backgroundColor: style.brightness == Brightness.dark
          ? Colors.grey[850]
          : Colors.grey[50], // Adjusts background color based on theme
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Card(
                color: style.brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.white, // Adjusts card color based on theme
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
                              if (!_isLogin) ...[
                                const SizedBox(height: 20),
                                UserImagePicker(
                                  onPickedImage: (pickedImage) {
                                    _selectedImage = pickedImage;
                                  },
                                ),
                                const SizedBox(height: 20),
                                AuthInput(
                                  onSaved: (newValue) {
                                    if (newValue == null) {
                                      return;
                                    }
                                    _enteredUserName = newValue;
                                  },
                                  obsecureText: false,
                                  labelText: 'Username',
                                  keyboardType: TextInputType.name,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().length < 4 ||
                                        value.trim().isEmpty) {
                                      return 'Username should be at least 4 characters.';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                              const SizedBox(height: 15),
                              AuthInput(
                                onSaved: (newValue) {
                                  if (newValue == null) {
                                    return;
                                  }
                                  _enteredEmail = newValue;
                                },
                                obsecureText: false,
                                labelText: 'Email Address',
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null ||
                                      !value.contains('@') ||
                                      value.trim().isEmpty) {
                                    return 'Please enter a valid email address.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 15),
                              AuthInput(
                                onSaved: (newValue) {
                                  if (newValue == null) {
                                    return;
                                  }
                                  _enteredPassword = newValue;
                                },
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
                              if (!_isLogin) ...[
                                AuthInput(
                                  onSaved: (newValue) {
                                    if (newValue == null) {
                                      return;
                                    }
                                    _confirmPassword = newValue;
                                  },
                                  labelText: 'Confirm Password',
                                  obsecureText: true,
                                  keyboardType: TextInputType.text,
                                  validator: (value) {
                                    if (value == null ||
                                        value != _enteredPassword) {
                                      return 'Passwords do not match.';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                              if (_isAuthenticating)
                                const CircularProgressIndicator(),
                              if (!_isAuthenticating)
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
                                      horizontal:
                                          (constraints.maxWidth - 70) / 2,
                                    ),
                                  ),
                                  onPressed: _submit,
                                  child: Text(
                                    _isLogin ? 'Log in' : 'Sign up',
                                    style: const TextStyle(fontSize: 17),
                                  ),
                                ),
                              if (!_isAuthenticating)
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
                                      color:
                                          Theme.of(context).colorScheme.primary,
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
