import 'dart:io';
import 'package:flutter/material.dart';
import 'package:memories_app/widgets/image_input.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class AddNewMemoryScreen extends StatefulWidget {
  const AddNewMemoryScreen({super.key});

  @override
  State<AddNewMemoryScreen> createState() => _AddNewMemoryScreenState();
}

class _AddNewMemoryScreenState extends State<AddNewMemoryScreen> {
  final _titleController = TextEditingController();
  File? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveMemory() async {
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
    try {
      final ref = FirebaseStorage.instance
          .ref()
          .child('memories')
          .child('${DateTime.now().toIso8601String()}.jpg');

      await ref.putFile(_selectedImage!);

      final imageUrl = await ref.getDownloadURL();

      // Save the memory details to Firestore
      await FirebaseFirestore.instance.collection('memories').add({
        'title': _titleController.text,
        'imageUrl': imageUrl,
        // Add other details like the date, etc. if necessary
      });
    } catch (error) {
      if (error is FirebaseException) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.message!),
          ),
        );
      } else {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('An error occurred. Please try again.'),
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
            // LocationInput(
            //   onSelectLocation: (location) {
            //     _selectedLocation = location;
            //   },
            // ),
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
