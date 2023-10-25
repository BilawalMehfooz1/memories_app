import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:memories_app/widgets/profile_image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _userImageFile;
  String? userEmail;
  String? currentProfileImage;
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get()
        .then((userData) {
      if (mounted) {
        setState(() {
          userEmail = user.email;
          currentProfileImage = userData['image_url'];
          currentUsername = userData['username'];
          _nameController.text = currentUsername ?? '';
        });
      }
    });
  }

  void _pickedImage(File image) {
    _userImageFile = image;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 40),
            LocalUserImagePicker(
                onPickedImage: _pickedImage,
                currentImageUrl: currentProfileImage),
            const SizedBox(height: 16),
            // if (userEmail != null)
            //   ListTile(
            //     leading: const Icon(Icons.email),
            //     title: Text(userEmail!),
            //   ),
            // const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextFormField(
                controller: _nameController,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onBackground,
                ),
                decoration: InputDecoration(
                  labelText: 'Username',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12.0, vertical: 8.0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a name.';
                  }
                  if (value.length < 4) {
                    return 'Name should be at least 4 characters long.';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(
                  fontSize: 20,
                ),
              ),
              child: const Text('Save Profile'),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
