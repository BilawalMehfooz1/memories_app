import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:memories_app/widgets/auth_input_field.dart';
import 'package:memories_app/widgets/user_image_picker.dart';

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
  File? _selectedImage;
  var _isLogin = true;

  void _submit() async {
    UserCredential userCredentials;
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill the form correctly.'),
        ),
      );
      return;
    }
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
        print(imageUrl);
      }
    } on FirebaseAuthException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.message ?? 'Authentication failed.',
          ),
        ),
      );
    }
  }

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
                                UserImagePicker(
                                  onPickedImage: (pickedImage) {
                                    _selectedImage = pickedImage;
                                  },
                                ),
                              const SizedBox(height: 10),
                              if (!_isLogin)
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
                                onPressed: _submit,
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
