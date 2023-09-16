import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/material.dart';
import 'package:memories_app/providers/tabscreen_provider.dart';
import 'package:memories_app/widgets/image_input.dart';

class AddNewMemoryScreen extends ConsumerStatefulWidget {
  const AddNewMemoryScreen({super.key});

  @override
  ConsumerState<AddNewMemoryScreen> createState() => _AddNewMemoryScreenState();
}

class _AddNewMemoryScreenState extends ConsumerState<AddNewMemoryScreen> {
  final _titleController = TextEditingController();
  File? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveMemory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    if (_titleController.text.trim().length < 4 ||
        _titleController.text.trim().isEmpty ||
        _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title should be atleast 4 characters.'),
        ),
      );
      return;
    }

    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image.'),
        ),
      );
      return;
    }
    ref.read(tabScreenProvider.notifier).changeScreen(0);
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('memories')
          // Improve image naming with user UID for uniqueness
          .child('${DateTime.now().toIso8601String()}_${user.uid}.jpg');

      await ref.putFile(_selectedImage!);

      final imageUrl = await ref.getDownloadURL();

      // Save the memory details to Firestore
      await FirebaseFirestore.instance.collection('memories').add({
        'title': _titleController.text,
        'imageUrl': imageUrl,
        'userID': user.uid,
      });
    } catch (error) {
      String errorMessage;
      if (error is FirebaseException) {
        // Mapping known errors to user-friendly messages
        switch (error.code) {
          case 'operation-not-allowed':
            errorMessage = 'Saving memories is not allowed currently.';
            break;
          case 'user-not-found':
            errorMessage = 'User not found.';
            break;
          // Add other cases as needed.
          default:
            errorMessage = error.message ?? 'An unknown error occurred.';
            break;
        }
      } else {
        errorMessage = 'An error occurred. Please try again.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              controller: _titleController,
            ),
            const SizedBox(height: 12),
            ImageInput(
              onSelectImage: (image) {
                _selectedImage = image;
              },
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _saveMemory,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            )
          ],
        ),
      ),
    );
  }
}
