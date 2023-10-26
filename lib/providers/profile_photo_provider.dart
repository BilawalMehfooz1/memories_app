import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

final _firebase = FirebaseAuth.instance;

final profilePictureUrlProvider = StateProvider<String?>((ref) => null);

final imagePickerProvider = Provider<void Function(BuildContext)>((ref) {
  return (context) => _showImageOptionsModal(context, ref);
});

void _showImageOptionsModal(BuildContext context, ProviderRef ref) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15.0)),
    ),
    builder: (ctx) {
      return Container(
        padding: const EdgeInsets.only(top: 15.0, bottom: 10.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 15.0),
                height: 5.0,
                width: 30.0,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 15.0),
              leading: const Text('Profile Photo',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.grey),
                onPressed: () async {
                  _showLoadingDialog(context);
                  final currentUser = _firebase.currentUser;
                  if (currentUser != null) {
                    final uid = currentUser.uid;
                    final userDocRef =
                        FirebaseFirestore.instance.collection('users').doc(uid);
                    try {
                      await userDocRef.update({'image_url': FieldValue.delete()});

                      // Update the profilePictureUrlProvider state to null
                      ref.read(profilePictureUrlProvider.notifier).state = null;

                      Navigator.pop(context); // Close the loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Profile photo deleted successfully!'),
                        ),
                      );
                      Navigator.pop(context); // Close the modal sheet
                    } catch (error) {
                      Navigator.pop(context); // Close the loading dialog
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting photo: $error'),
                        ),
                      );
                    }
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 15.0, top: 10.0),
              child: Row(
                children: [
                  _buildOption(
                    context: context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    theme: Theme.of(ctx),
                    onTap: () async {
                      Navigator.pop(context); // Close the modal sheet
                      final pickedImage = await _pickImage(ImageSource.camera);
                      if (pickedImage != null) {
                        await _uploadImage(pickedImage, context, ref);
                      }
                    },
                  ),
                  const SizedBox(width: 20.0),
                  _buildOption(
                    context: context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    theme: Theme.of(ctx),
                    onTap: () async {
                      Navigator.pop(context); // Close the modal sheet
                      final pickedImage = await _pickImage(ImageSource.gallery);
                      if (pickedImage != null) {
                        await _uploadImage(pickedImage, context, ref);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<File?> _pickImage(ImageSource source) async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: source);
  return pickedFile != null ? File(pickedFile.path) : null;
}

Future<void> _uploadImage(File image, BuildContext context, ProviderRef ref) async {
  _showLoadingDialog(context);
  final currentUser = _firebase.currentUser;
  if (currentUser != null) {
    final uid = currentUser.uid;
    final storageRef =
        FirebaseStorage.instance.ref().child('user_images').child('$uid.jpg');
    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);

    try {
      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();
      await userDocRef.update({'image_url': imageUrl});

      // Update the profilePictureUrlProvider state
      ref.read(profilePictureUrlProvider.notifier).state = imageUrl;

      Navigator.pop(context); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photo updated successfully!'),
        ),
      );
    } catch (error) {
      Navigator.pop(context); // Close the loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading photo: $error'),
        ),
      );
    }
  }
}

Widget _buildOption({
  required BuildContext context,
  required IconData icon,
  required String label,
  required ThemeData theme,
  required VoidCallback onTap,
}) {
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      CircleAvatar(
        radius: 25,
        backgroundColor: Theme.of(context).colorScheme.background,
        child: IconButton(
          icon: Icon(icon, color: const Color.fromRGBO(5, 178, 74, 1)),
          onPressed: onTap,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        label,
        style: TextStyle(
          color: theme.brightness == Brightness.light
              ? Colors.black
              : Colors.white,
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}

void _showLoadingDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            const SizedBox(width: 20),
            Text("Processing..."),
          ],
        ),
      );
    },
  );
}
