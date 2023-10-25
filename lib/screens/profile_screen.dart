import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  final String? username;
  final String? profileImageUrl;

  const ProfileScreen({this.username, this.profileImageUrl, Key? key})
      : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _userImageFile;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.username ?? '';
  }

  Future<void> _saveProfile() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      // Form isn't valid!
      return;
    }

    // Show a confirmation dialog
    final isConfirmed = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirmation'),
            content: const Text('Do you really want to save the changes?'),
            actions: [
              TextButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
              ),
              TextButton(
                child: const Text('Yes'),
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
              ),
            ],
          ),
        ) ??
        false;

    if (!isConfirmed) {
      return;
    }

    if (_userImageFile == null) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick an image!'),
        ),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;

    final ref = FirebaseStorage.instance
        .ref()
        .child('user_images')
        .child('${user!.uid}.jpg');

    await ref.putFile(_userImageFile!);
    final imageUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'username': _nameController.text,
      'image_url': imageUrl,
    });
  }

  void _editUsername(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return SingleChildScrollView(
            child: Padding(
              padding:
                  EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text('Please enter username',
                          style: TextStyle(
                              color: Theme.of(ctx).colorScheme.onBackground,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextField(
                      controller: _nameController,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onBackground,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          _saveProfile();
                          Navigator.of(ctx).pop();
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    ThemeMode currentThemeMode =
        Theme.of(context).brightness == Brightness.light
            ? ThemeMode.light
            : ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          CircleAvatar(
            radius: 80,
            backgroundImage: widget.profileImageUrl != null
                ? NetworkImage(widget.profileImageUrl!)
                : null,
            child: IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () {
                // TODO: Open the image picker here
              },
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(
              Icons.person,
              size: 30,
            ),
            title: Text(
              _nameController.text,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'This is the username that you entered while creating account.',
              style: TextStyle(
                color: currentThemeMode == ThemeMode.dark
                    ? Colors.grey[500]
                    : Colors.black54,
              ),
            ),
            trailing: IconButton(
              icon: Icon(Icons.edit,
                  color: Theme.of(context).colorScheme.primary),
              onPressed: () => _editUsername(context),
            ),
          ),
        ],
      ),
    );
  }
}
