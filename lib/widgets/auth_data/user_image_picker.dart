import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({
    Key? key,
    required this.onPickedImage,
  }) : super(key: key);

  final void Function(File pickedImage) onPickedImage;

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImageFile;

  Future<void> _compressAndSetImage(File image) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      image.absolute
          .path, // This path denotes that the compressed image will overwrite the original image
      quality: 90, // Compression quality. Adjust as needed.
    );

    if (result != null) {
      setState(() {
        _pickedImageFile =
            File(result.path); // Here, result should be of type File.
      });
      widget.onPickedImage(_pickedImageFile!);
    }
  }

  void _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (pickedImage == null) {
      return;
    }

    await _compressAndSetImage(File(pickedImage.path));
  }

  void _pickGalleryImage() async {
    final pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage == null) {
      return;
    }

    await _compressAndSetImage(File(pickedImage.path));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey[600],
          foregroundImage:
              _pickedImageFile != null ? FileImage(_pickedImageFile!) : null,
          child: _pickedImageFile == null
              ? Icon(
                  Icons.person,
                  size: 60,
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
        )
      ],
    );
  }
}
