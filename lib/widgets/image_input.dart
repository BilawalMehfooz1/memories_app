import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatefulWidget {
  const ImageInput({
    super.key,
    required this.onSelectImage,
  });

  final void Function(File image) onSelectImage;

  @override
  State<ImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<ImageInput> {
  String? _lastImageType;
  File? _selectedImage;

  // Taken by camera
  void _takePicture() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.camera,
    );
    if (pickedImage == null) {
      return;
    }

    setState(() {
      _selectedImage = File(pickedImage.path);
      _lastImageType = 'camera';
    });

    widget.onSelectImage(_selectedImage!);
  }

  // Picture from gallery
  void _fromGalleryImage() async {
    final imagePicker = ImagePicker();
    final pickedImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedImage == null) {
      return;
    }
    setState(() {
      _selectedImage = File(pickedImage.path);
      _lastImageType = 'gallery';
    });
    widget.onSelectImage(_selectedImage!);
  }

  // Method to change picture by tapping on selected picture
  void _onTapImage() {
    if (_lastImageType == 'camera') {
      _takePicture();
    } else {
      _fromGalleryImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
          onPressed: _takePicture,
          icon: const Icon(Icons.camera),
          label: const Text('Take Picture'),
        ),
        TextButton.icon(
          onPressed: _fromGalleryImage,
          icon: const Icon(Icons.image),
          label: const Text('Choose from gallery'),
        ),
      ],
    );

    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _onTapImage,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Theme.of(context).colorScheme.onBackground,
        ),
      ),
      alignment: Alignment.center,
      height: 250,
      width: double.infinity,
      child: content,
    );
  }
}
