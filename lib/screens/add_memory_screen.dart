import 'package:flutter/material.dart';
import 'package:memories_app/widgets/image_input.dart';

class AddNewMemoryScreen extends StatelessWidget {
  const AddNewMemoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              // controller: _titleController,
            ),
            const SizedBox(height: 12),
            ImageInput(
              onSelectImage: (image) {
                // _selectedImage = image;
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
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            )
          ],
        ),
      ),
    );
  }
}
