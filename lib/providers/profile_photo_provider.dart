import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final imagePickerProvider = Provider<void Function(BuildContext)>((ref) {
  return (context) => _showImageOptionsModal(context);
});

void _showImageOptionsModal(BuildContext context) {
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
                margin: const EdgeInsets.only(bottom: 15.0), // Increased space
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
                onPressed: () {},
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: 15.0, top: 10.0), // Increased space
              child: Row(
                children: [
                  _buildOption(
                    context: context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    theme: Theme.of(ctx),
                    onTap: () {},
                  ),
                  const SizedBox(width: 20.0),
                  _buildOption(
                    context: context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    theme: Theme.of(ctx),
                    onTap: () {},
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
        backgroundColor: Theme.of(context)
            .colorScheme
            .background, // Set to scaffold background
        child: IconButton(
          icon: Icon(
            icon,
            color: const Color.fromRGBO(5, 178, 74, 1),
          ),
          onPressed: onTap,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        label,
        style: TextStyle(
          color: theme.brightness == Brightness.light
              ? Colors.black
              : Colors.white, // Set text color based on theme brightness
        ),
      ),
      const SizedBox(height: 10),
    ],
  );
}
