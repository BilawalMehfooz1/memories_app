import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';

class LocalUserImagePicker extends StatefulWidget {
  final void Function(File pickedImage) onPickedImage;
  final String? currentImageUrl;

  const LocalUserImagePicker({
    required this.onPickedImage,
    this.currentImageUrl,
    super.key,
  });

  @override
  State<LocalUserImagePicker> createState() => _LocalUserImagePickerState();
}

class _LocalUserImagePickerState extends State<LocalUserImagePicker> {
  File? _pickedImageFile;
  ImageProvider? imageProvider;

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
      maxWidth: 150,
    );

    if (pickedImage != null) {
      setState(() {
        _pickedImageFile = File(pickedImage.path);
      });
      widget.onPickedImage(_pickedImageFile!);
    }
  }

  void _pickGalleryImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      setState(() {
        _pickedImageFile = File(pickedImage.path);
      });
      widget.onPickedImage(_pickedImageFile!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 100,
          backgroundColor: Colors.grey[600],
          backgroundImage: _pickedImageFile != null
              ? FileImage(_pickedImageFile!)
              : (widget.currentImageUrl != null &&
                      widget.currentImageUrl!.isNotEmpty
                  ? CachedNetworkImageProvider(widget.currentImageUrl!)
                      as ImageProvider
                  : null),
          child: _pickedImageFile == null && widget.currentImageUrl == null
              ? Icon(
                  Icons.person,
                  size: 150,
                  color: Colors.grey[900],
                )
              : null,
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Picture'),
            ),
            TextButton.icon(
              onPressed: _pickGalleryImage,
              icon: const Icon(Icons.image),
              label: const Text('From Gallery'),
            ),
          ],
        ),
      ],
    );
  }
}
